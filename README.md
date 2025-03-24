# SMS-spam-detection
This project analyzes SMS messages to classify them as spam or ham (legitimate) using machine learning. By comparing model performance metrics, we can evaluate how effectively spam can be filtered from legit texts from friends and family. 

# Data, Methodology, and Tools Used
The project uses R and a few additional packages that you may need to install:
1. tm (text mining, creating corpus, preprocessing)
2. snowballC (word stemming)
3. wordcloud (visulalization of frequent words)
4. e1071 (Naive bayes)
5. ggplot2

**Data:** Almeida, T. & Hidalgo, J. (2011). SMS Spam Collection [Dataset]. UCI Machine Learning Repository. 
I have also uploaded the dataset in the repository. 

**Methods:** Text cleaning, term-frequency analysis, and probabilistic modeling.

**Results:** 97.49% accuracy for ham texts and 86.4% accuracy for spam detection and word clouds reveal spam triggers (example: free, win)

## License
MIT License.

~ f4gun

Last updated: March 2025




