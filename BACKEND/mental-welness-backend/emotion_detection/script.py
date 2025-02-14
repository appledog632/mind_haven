from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from PIL import Image
import torch
import torch.backends.cudnn as cudnn
import torchvision.transforms as transforms
import numpy as np
import io
import asyncio
from concurrent.futures import ThreadPoolExecutor
from typing import Dict
from repvgg import create_RepVGG_A0 as create

model = create(deploy=True)
emotions = ("anger", "contempt", "disgust", "fear",
            "happy", "neutral", "sad", "surprise")
executor = ThreadPoolExecutor(max_workers=4)  # Adjust based on your hardware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def init(device: str):
    model.to(device)
    model.load_state_dict(torch.load(
        "weights/repvgg.pth", map_location=device))
    cudnn.benchmark = True
    model.eval()


@app.on_event("startup")
async def startup_event():
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    init(device)


def process_image(image: np.ndarray) -> torch.Tensor:
    """Synchronous image processing"""
    transform = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225])
    ])
    return transform(Image.fromarray(image))  # type: ignore


def predict(image_tensor: torch.Tensor) -> Dict[str, str]:
    """Synchronous prediction"""
    with torch.no_grad():
        device = next(model.parameters()).device
        outputs = model(image_tensor.to(device))
        probabilities = torch.nn.functional.softmax(outputs, dim=1)
    return {emotions[i]: f"{probabilities[0][i].item()*100:.1f}" for i in range(len(emotions))}


@app.post("/emotion")
async def detect_emotion(file: UploadFile = File(...)):
    if not file.content_type.startswith('image/'):  # type: ignore
        raise HTTPException(400, detail="Invalid file type")

    try:
        image_data = await file.read()
        image = Image.open(io.BytesIO(image_data)).convert('RGB')
        image_np = np.array(image)

        loop = asyncio.get_event_loop()
        image_tensor = await loop.run_in_executor(executor, process_image, image_np)

        batch_tensor = image_tensor.unsqueeze(0)
        predictions = await loop.run_in_executor(executor, predict, batch_tensor)

        return {"emotions": predictions}

    except Exception as e:
        raise HTTPException(500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
