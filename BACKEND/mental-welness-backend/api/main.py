from typing import Dict, List
import random

from ollama import chat
from ollama import ChatResponse

from fastapi import FastAPI
from pydantic import BaseModel
import aiosqlite


class CustomFastAPI(FastAPI):
    db: aiosqlite.Connection


question_p1 = {
    "anxiety": [
        "I rarely experience dryness of my mouth due to anxiety",
        "I can breathe normally and calmly, even in stressful situations.",
        "My hands remain steady and calm, even when I face challenging tasks.",
        "I feel confident in situations where I might be the center of attention.",
        "I remain composed and far from panic, even in difficult moments.",
        "I am rarely aware of my heart rate unless I'm physically exerting myself.",
        "I feel calm and safe, with no underlying fears or worries.",
        "I feel at ease and rarely experience uneasiness without a clear reason.",
        "I approach everyday situations and tasks without excessive worry.",
        "I remain physically relaxed and comfortable, without symptoms like sweating or shaking"
    ],
    "depression": [
        "I am able to experience positive feelings and moments of joy.",
        "I find it easy to take the initiative and get things done.",
        "I feel excited about the future and have things to look forward to.",
        "I feel cheerful and content most of the time.",
        "I can find enthusiasm for things that interest me.",
        "I feel confident and recognize my worth as a person.",
        "I find meaning and purpose in life.",
        "I enjoy activities and hobbies that I have always loved.",
        "I feel free from unnecessary guilt and understand that not everything is my fault.",
        "I find it easy to focus and make decisions, even about small matters."
    ],
    "stress": [
        "I remain composed and avoid over-reacting to situations.",
        "I feel calm and do not rely on nervous energy to get through the day.",
        "I handle challenges without feeling agitated or restless.",
        "I find it easy to relax, even after a busy day.",
        "I patiently deal with interruptions without frustration.",
        "I stay calm and avoid feeling overly sensitive or touchy.",
        "I can relax my mind and maintain a sense of calm when needed.",
        "I feel capable of managing the demands placed on me without feeling overwhelmed.",
        "I rarely get irritated by minor inconveniences and handle them smoothly.",
        "I can switch off my thoughts and fully enjoy breaks or downtime."
    ],
    "focus": [
        "I remain conscious of my emotions shortly after they arise.",
        "I handle objects with care and pay attention to avoid breaking or spilling things.",
        "I find it easy to stay focused on what’s happening in the present.",
        "I walk mindfully, paying attention to my surroundings as I move.",
        "I notice feelings of physical tension or discomfort before they escalate.",
        "I remember a person’s name even after hearing it for the first time.",
        "I act with awareness and avoid functioning on autopilot.",
        "I perform activities attentively, staying fully engaged in the process.",
        "I balance staying focused on my goals while remaining mindful of my current actions.",
        "I complete jobs or tasks with full awareness of what I’m doing."
    ],
    "productivity": [
        "I regularly complete tasks ahead of time, without delay.",
        "I get up promptly and start my day without hesitation.",
        "I make decisions quickly and confidently.",
        "I take immediate action on work that needs to be done.",
        "I complete all tasks before relaxing in the evening.",
        "I plan and buy essential items well in advance.",
        "When preparing for a deadline, I stay focused and avoid distractions.",
        "I accomplish everything I plan to do in a day.",
        "I finish assignments well ahead of their deadlines.",
        "I always complete tasks with plenty of time to spare."
    ],
    "healthy_relationship": [
        "I feel uncomfortable expressing my thoughts and feelings to others.",
        "I do not listen actively when others are speaking to me.",
        "I avoid engaging in open and honest conversations.",
        "I do not seek to understand others' perspectives, even if I disagree.",
        "I feel my communication style is ineffective in my relationships.",
        "I do not trust my family and friends.",
        "I do not feel respected by others in my relationships.",
        "I do not maintain healthy boundaries with others.",
        "I do not feel supported by my friends and family during difficult times.",
        "I feel uncomfortable asking for help from others."
    ],
}


question_p2 = {
    "unhealthy_skin": [
        "The appearance of my skin does not affect how I feel.",
        "My skin does not reflect the state of my health.",
        "I do not feel that others stare at my skin lesions.",
        "When I look into a mirror, I'm mostly admiring my skin.",
        "I’m not worried that my skin problem will worsen.",
        "I rarely think about what life would be like with healthy skin.",
        "I believe my skin makes me just as attractive as others.",
        "I do not avoid attending events because of my skin.",
        "I pay enough attention to my nutrition to maintain healthy skin.",
        "I believe my skin health has already reached its peak."
    ],
    "poor_mental_state": [
        "I feel mentally calm and at peace most of the time.",
        "I can handle stressful situations without feeling overwhelmed.",
        "I feel emotionally stable and in control of my thoughts.",
        "I am able to stay positive even during challenging times.",
        "I feel motivated and energetic throughout the day.",
        "I find it easy to balance my emotions and maintain a steady mood.",
        "I feel confident about managing my daily responsibilities and tasks.",
        "I experience a good sense of overall mental well-being and clarity.",
        "I can easily let go of negative thoughts and focus on the present moment.",
        "I feel emotionally resilient and capable of bouncing back from setbacks."
    ],
    "physical_health": [
        "I consider my physical health a priority in my life.",
        "I understand the importance of a balanced diet for my health.",
        "My health is an important part of my identity.",
        "I value expert advice and consider it helpful for maintaining my health.",
        "I believe home-cooked meals are better for my health than hostel food.",
        "I think having knowledge about the human body is crucial for living a healthy life.",
        "I believe maintaining a regular routine and getting adequate sleep is essential, even during exams.",
        "I find time for exercise without it disturbing my daily routine.",
        "I am satisfied with my physical health.",
        "I feel confident and happy about my physical health."
    ],
    "smoking": [
        "I feel no urge to smoke, even after a few hours without it.",
        "The idea of not having cigarettes does not cause me stress.",
        "I don’t feel the need to carry cigarettes before going out.",
        "I believe I do not smoke excessively.",
        "I never drop everything to go out and buy cigarettes.",
        "I rarely smoke, if at all.",
        "I avoid smoking because of its risks to my health.",
        "can easily go a full day or more without smoking.",
        "I feel proud of myself for not smoking.",
        "I don’t rely on smoking to feel relaxed or focused."
    ],
    "skipping_meals": [
        "I always ensure I have my meals on time, regardless of other priorities.",
        "I feel more focused and energized because I don’t skip meals.",
        "When I feel stressed, I make an effort to eat properly instead of skipping meals",
        "I avoid skipping meals to prevent feelings of tiredness or irritability",
        "I believe maintaining regular meals is essential for achieving personal and professional goals.",
        "Even with a busy schedule, I ensure I find time to eat all my meals.",
        "Eating meals regularly helps me perform daily tasks effectively and stay focused.",
        "I understand that skipping meals is not a healthy practice for long-term well-being.",
        "I maintain regular meal times, which positively impacts my sleep patterns.",
        "I feel satisfied and happy when I stick to my regular meal routine."
    ],
    "screen_time": [
        "It is my need to chat/surf on the internet for 2-3 hours daily.",
        "I don’t have poor eyesight.",
        "I feel relaxed when I’m away from the web.",
        "I don’t overreact when people interfere while I’m busy scrolling reels.",
        "I sleep well without being disturbed by late-night log-ins.",
        "I prefer not using screens during meals.",
        "I set limits or rules for my screen time.",
        "Screen time affects my productivity at work, college, or home.",
        "I pretend to be on screen to avoid social interactions.",
        "I often prioritize screen usage over spending time with family or friends"
    ],
    "hair_loss": [
        "I do not worry about my hair loss being serious.",
        "My hair condition does not cause me stress.",
        "I feel confident enough to go out despite my hair.",
        "I do not feel self-conscious about my hair.",
        "My hair condition does not affect my self-esteem.",
        "I am satisfied with the hair treatments I've tried.",
        "I am optimistic about the possibility of regrowing my hair.",
        "I have not received negative comments about my hair.",
        "I believe society places less emphasis on hair as a beauty standard.",
        "I do not feel embarrassed about my hair condition."
    ]
}

concerns_list = {
    "skipping_meals": [
        "Eat meals",
        "Meal prep",
        "Set reminders",
        "Healthy snacks",
        "Stay hydrated"
    ],
    "smoking": [
        "Chew gum",
        "Deep breathing",
        "Track progress",
        "Carry Nicotex Patch",
        "Stay active"
    ],
    "bad_skin": [
        "Morning routine",
        "Hydrate",
        "Healthy diet",
        "Avoid touching",
        "Evening routine"
    ],
    "poor_physical_health": [
        "Exercise",
        "Balanced diet",
        "Quality sleep",
        "Stretching",
        "Walk breaks"
    ],
    "poor_mental_state": [
        "Meditation",
        "Gratitude journal",
        "Socialize",
        "Hobby time",
        "Limit negativity"
    ],
    "screen_time": [
        "Frequent breaks",
        "Blue light filter",
        "Screen-free meals",
        "Outdoor time",
        "Set cutoff"
    ],
    "hair_loss": [
        "Scalp massage",
        "Gentle shampoo",
        "Biotin-rich food",
        "Avoid heat",
        "Stress relief"
    ]
}


app = CustomFastAPI()


@app.get("/questions/{concern}")
def get_questions(concern: str):
    concerns = concern.split("+")
    q1 = []
    q2 = []
    final_questions = []
    for key in question_p2.keys():
        if key in concerns:
            quest = random.sample(question_p2[key], k=5)
            quest = [f"[{key.lower()}] {q}" for q in quest]
            q2.extend(quest)
        else:
            quest = random.sample(question_p2[key], k=1)
            quest = [f"[{key.lower()}] {q}" for q in quest]
            q2.extend(quest)
    for key in question_p1.keys():
        quest = random.sample(question_p1[key], k=2)
        quest = [f"[{key.lower()}] {q}" for q in quest]
        q1.extend(quest)

    final_questions.extend(q1[:15])
    final_questions.extend(q2[:15])
    return final_questions[:2]


@app.get('/concerns')
async def concerns():
    final_goals = []
    for key in concerns_list.keys():
        final_goals.append(key)

    return final_goals


@app.get('/goals/{concerns}')
async def goals(concerns: str):
    final_goals = []
    for key in concerns.split('+'):
        quest = random.sample(concerns_list[key], k=3)
        final_goals.extend(quest)

    final_goals = random.sample(final_goals, k=3)
    return final_goals


@app.get('/chat/{query}')
async def chatbot(query: str, interpretation: str | None = None):
    response: ChatResponse = chat(model='chat_bot', messages=[
        {
            'role': 'system',
            'content': interpretation,
        },
        {
            'role': 'user',
            'content': query,
        },
    ])
    return response.message.content


class AnswerItem(BaseModel):
    answer: str
    scale: int
    emotion: dict


class Score(BaseModel):
    parameters: Dict[str, None | int]
    interpretation: dict
    emotion: str


@app.post('/answers')
async def answer(answers: List[AnswerItem]) -> Score:
    """Returns Score on based on return results"""
    concerns = ["anxiety", "depression", "stress", "focus", "productivity", "healthy_relationship", "unhealthy_skin",
                "poor_mental_state", "physical_health", "smoking", "skipping_meals", "screen_time", "hair_loss"]
    results: Dict[str, None | int] = {x: None for x in concerns}
    emotion_state: Dict[str, float] = {
        "anger": 0,
        "contempt": 0,
        "disgust": 0,
        "fear": 0,
        "happy": 0,
        "neutral": 0,
        "sad": 0,
        "surprise": 0
    }
    count = {x: 0 for x in concerns}
    interpretation = dict()
    for ans in answers:
        tags = ans.answer.split(' ')[0][1:-1]

        if results[tags] is None:
            results[tags] = ans.scale
        else:
            results[tags] = ans.scale + results[tags]  # type: ignore

        count[tags] += 1
        interpretation = {key: _get_severity(
            results[key], key, count[tags]) for key in results.keys()}
        for i in emotion_state.keys():
            emotion_state[i] += float(ans.emotion[i])

    return Score(
        parameters=results,  # type: ignore
        interpretation=interpretation,
        emotion=max(emotion_state, key=lambda x: emotion_state[x])
    )


def _get_severity(score: int | None, category: str, count: int) -> str | None:
    """Returns severity level based on DASS-21 scoring guidelines"""
    levels = {0: 'Worst', 1: 'Mild', 2: 'Good', 3: 'Great'}
    if score is None:
        return score
    avg = round(score/count)
    if avg > 3:
        return levels[3]
    return levels[avg]


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
