def get_recommendations(phq9_score):
    if phq9_score < 5:
        return "Your depression levels are minimal. Keep maintaining a healthy lifestyle."
    elif 5 <= phq9_score < 10:
        return "Mild depression detected. Consider seeking support from friends or family."
    elif 10 <= phq9_score < 15:
        return "Moderate depression detected. It's advisable to consult with a mental health professional."
    elif 15 <= phq9_score < 20:
        return "Moderately severe depression detected. Professional treatment is recommended."
    else:
        return "Severe depression detected. Immediate professional help is strongly recommended."