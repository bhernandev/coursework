library(tidyverse)
library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(caret)
library(broom)

########################################
# LOAD AND PARSE ARTICLES
########################################

# read in the business and world articles from files
# combine them both into one data frame called articles
business <- read_tsv('business.tsv', quote = "\'")
world <- read_tsv('world.tsv', quote = "\'")
articles <- rbind(business, world)

# create a corpus from the article snippets
# using the Corpus and VectorSource functions
corpus <- Corpus(VectorSource(articles$snippet))

# create a DocumentTermMatrix from the snippet Corpus
# remove stopwords, punctuation, and numbers
dtm <- DocumentTermMatrix(corpus, list(weighting=weightBin,
                                       stopwords=T,
                                       removePunctuation=T,
                                       removeNumbers=T))

# convert the DocumentTermMatrix to a sparseMatrix
X <- sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)

# set a seed for the random number generator so we all agree
set.seed(42)

########################################
# YOUR SOLUTION BELOW
########################################

# create a train / test split
sample_indices <- sample(1:nrow(X), nrow(X) * 0.8)
train <- X[sample_indices,]
train_labels <- articles$section_name[sample_indices]
test <- X[-sample_indices,]
test_labels <- articles$section_name[-sample_indices]

# cross-validate logistic regression with cv.glmnet (family="binomial"), measuring auc
nyt_model <- cv.glmnet(train, train_labels, family="binomial", type.measure="class")

# plot the cross-validation curve
plot(nyt_model)

# evaluate performance for the best-fit model
# note: it's useful to explicitly cast glmnet's predictions
# use as.numeric for probabilities and as.character for labels for this
test_results <- data.frame(test_labels)
test_results <- rename(test_results, labels = test_labels)
test_results$prob <- as.numeric(predict(nyt_model, newx = test, type="response"))
test_results$predictions <- as.factor(predict(nyt_model, newx = test, type="class"))

# compute accuracy
mean(test_results$labels == test_results$predictions)

# look at the confusion matrix
# table(test_results$predictions, test_results$labels)
confusionMatrix(test_results$predictions, test_results$labels)

# plot an ROC curve and calculate the AUC
# (see last week's notebook for this)
pred <- prediction(test_results$prob, test_results$labels)
perf_nb <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_nb)
performance(pred, 'auc')

# show weights on words with top 10 weights for business
# use the coef() function to get the coefficients
# and tidy() to convert them into a tidy data frame
word_weights <- tidy(coef(nyt_model))
word_weights$exponential <- exp(word_weights$value)
word_weights %>%
  filter(value < 0) %>%
  arrange(value) %>%
  head(10)

# show weights on words with top 10 weights for world
word_weights %>%
  filter(value > 0) %>%
  arrange(desc(value)) %>%
  head(100)

