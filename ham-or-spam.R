# Install and load necessary packages 
install.packages(c("tm","SnowballC", "wordcloud","e1071","gmodels"))

library(tm)
library(SnowballC)
library(ggplot2)
library(wordcloud)
library(e1071)
library(gmodels)

# Import file and change column names 
sms_data <- read.delim("C:\\Users\\lenovo\\Downloads\\ham-or-spam\\SMSSpamCollection.txt", 
                       header = FALSE, 
                       sep = "\t", 
                       quote = "", 
                       stringsAsFactors = FALSE)
colnames(sms_data) <- c("label", "text")
str(sms_data) # check structure
head(sms_data)
which(!complete.cases(sms_data)) #check for any missing values 

#Exploratory data analysis
sms_data$textlength <- nchar(sms_data$text)
# Plot using ggplot2 
ggplot(sms_data, aes(textlength, fill = label)) + 
  geom_histogram(binwidth = 20, alpha = 0.8, position = "identity") +
  labs(
    title = "Distribution of Text Lengths by Spam/Ham",
    x = "Text Length",
    y = "Frequency",
    fill = "Type"
  ) +
  theme_minimal()

#create a corpus 
sms_corpus <- Corpus(VectorSource(sms_data$text))
print(sms_corpus)
inspect(sms_corpus[1:3])

# Clean the corpus 
sms_corpus_clean <- tm_map(sms_corpus, tolower)
sms_corpus_clean <- tm_map(sms_corpus_clean, removeNumbers)
sms_corpus_clean <- tm_map(sms_corpus_clean, removePunctuation)
sms_corpus_clean <- tm_map(sms_corpus_clean, removeWords, stopwords())
sms_corpus_clean <- tm_map(sms_corpus_clean, stripWhitespace)
inspect(sms_corpus_clean[1:3])

# Creating the document term matrix to tokenize the corpus
sms_dtm <- DocumentTermMatrix(sms_corpus_clean)

inspect(sms_dtm[1:10,10:15])

# Create a word cloud for Ham and Spam to understand common words used 
ham_cloud <- which(sms_data$label == "ham")
spam_cloud <- which(sms_data$label == "spam")

par(mar = c(0, 0, 0, 0))  # Removes margins from plot window

wordcloud(sms_corpus_clean[ham_cloud],
          min.freq = 40,
          scale=c(2.5,0.5),     # Set min and max scale
          max.words=40,       # Set top n words
          random.order=TRUE, # Words in random order
          use.r.layout=TRUE, # Use C++ collision detection
          colors=brewer.pal(8,"PuBu")) #colors

wordcloud(sms_corpus_clean[spam_cloud],
          min.freq = 40,
          scale=c(2.5,0.5),     # Set min and max scale
          max.words=40,       # Set top n words
          random.order=TRUE, # Words in random order
          use.r.layout=TRUE, # Use C++ collision detection
          colors=brewer.pal(9,"Reds")) #colors


# let's build a spam filter using Naive Bayes Classifier Algorithm 
# Partitioning the data into training data (75%) and test data (25%)
training_data <- sms_data[1:4180,]$label
testing_data <- sms_data[4181:5574,]$label

# Checking proportion of spam data in training and testing data 
prop.table(table(training_data))
prop.table(table(testing_data))

sms_dtm_train <- sms_dtm[1:4180,]
sms_dtm_test <- sms_dtm[4181:5574,]

sms_corpus_clean_train <- sms_corpus_clean[1:4180]
sms_corpus_clean_test <- sms_corpus_clean[4181:5574]

# Finding frequent words
frequent_words <- findFreqTerms(sms_dtm_test,5)
frequent_words[1:10]

# Create documents term matrix using frequent words 
freq_word_train <- sms_dtm_train[, frequent_words]
freq_word_test <- sms_dtm_test[, frequent_words]

# Creating a yes/no function as naive bayes classifier present or absent
# information each word in a message
yes_or_no <- function(x){
  y <- ifelse(x>0,1,0)
  y <- factor(y, levels= c(0,1), labels = c("No", "Yes"))
  y
}

# Apply the Yes/No function on train data and test data document term matrix 
# To know the presence of word 

sms_train <- apply(freq_word_train, 2, yes_or_no)
sms_test <- apply(freq_word_test, 2, yes_or_no)

sms_classifier <- naiveBayes(sms_train, training_data)
class(sms_classifier)

sms_test_prediction <- predict(sms_classifier, newdata= sms_test)
table(sms_test_prediction, testing_data)
prop.table(table(sms_test_prediction, testing_data))

# View it using gmodels 
CrossTable(sms_test_prediction, testing_data, 
           prop.chisq = F, prop.t= F, 
           dnn=c('Predicted','Actual'))
