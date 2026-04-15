from openai import OpenAI
import os
from dotenv import load_dotenv


load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def ask_chatbot(user_query, context=None):
    system_prompt = """
    You are a medical assistant chatbot for a medicine verification app.
    You help users understand medicines, detect fake drugs, and provide safe advice.
    Do NOT give strict prescriptions. Keep answers simple and safe.
    """

    if context:
        user_query = f"Context: {context}\n\nUser: {user_query}"

    response = client.chat.completions.create(
        model="gpt-4o-mini",  
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_query}
        ],
        temperature=0.5
    )

    return response.choices[0].message.content