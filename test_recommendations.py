import unittest
from models.recommendations import get_recommendations

class TestRecommendations(unittest.TestCase):

    def test_get_recommendations(self):
        self.assertEqual(get_recommendations(3), "Your depression levels are minimal. Keep maintaining a healthy lifestyle.")
        self.assertEqual(get_recommendations(7), "Mild depression detected. Consider seeking support from friends or family.")
        self.assertEqual(get_recommendations(12), "Moderate depression detected. It's advisable to consult with a mental health professional.")
        self.assertEqual(get_recommendations(17), "Moderately severe depression detected. Professional treatment is recommended.")
        self.assertEqual(get_recommendations(22), "Severe depression detected. Immediate professional help is strongly recommended.")

if __name__ == '__main__':
    unittest.main()