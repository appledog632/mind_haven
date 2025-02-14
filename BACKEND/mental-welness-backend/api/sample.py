from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = CustomFastAPI()


class AnswerItem(BaseModel):
    question: str
    # Assuming answer is 0-3 scale (common in psychological assessments)
    answer: int


class ScoreResult(BaseModel):
    anxiety: int
    depression: int
    stress: int
    overall: int
    interpretation: dict


@app.post('/answers/')
async def submit_answers(answers: List[AnswerItem]):
    category_scores = {
        'A': 0,  # Anxiety
        'D': 0,  # Depression
        'S': 0   # Stress
    }

    for item in answers:
        # Extract category from question prefix
        prefix = item.question[1] if len(item.question) > 1 else None
        if prefix not in category_scores:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid question format: {item.question}"
            )

        # Ensure answer is within valid range (0-3)
        if not 0 <= item.answer <= 3:
            raise HTTPException(
                status_code=400,
                detail=f"Invalid answer value: {
                    item.answer}. Must be between 0-3"
            )

        category_scores[prefix] += item.answer

    # Calculate total scores
    anxiety_score = category_scores['A'] * 2  # Standard DASS scoring
    depression_score = category_scores['D'] * 2
    stress_score = category_scores['S'] * 2
    total_score = anxiety_score + depression_score + stress_score

    # Create interpretation
    interpretation = {
        'anxiety': _get_severity(anxiety_score, 'anxiety'),
        'depression': _get_severity(depression_score, 'depression'),
        'stress': _get_severity(stress_score, 'stress'),
    }

    # Store in database (async example)
    async with app.db.cursor() as cursor:
        await cursor.execute('''
            INSERT INTO responses (anxiety, depression, stress, answers)
            VALUES (?, ?, ?, ?)
        ''', (anxiety_score, depression_score, stress_score, str(answers)))
        await app.db.commit()

    return ScoreResult(
        anxiety=anxiety_score,
        depression=depression_score,
        stress=stress_score,
        overall=total_score,
        interpretation=interpretation
    )


def _get_severity(score: int, category: str) -> str:
    """Returns severity level based on DASS-21 scoring guidelines"""
    thresholds = {
        'anxiety': [(0, 7), (8, 9), (10, 14), (15, 100)],
        'depression': [(0, 9), (10, 13), (14, 20), (21, 100)],
        'stress': [(0, 14), (15, 18), (19, 25), (26, 100)]
    }
    levels = ['Normal', 'Mild', 'Moderate', 'Severe', 'Extremely Severe']

    for i, (low, high) in enumerate(thresholds[category]):
        if low <= score <= high:
            return levels[i]
    return 'Unknown'
