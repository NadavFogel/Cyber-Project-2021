import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from numpy import asarray
from PIL import Image

# Load training data
data = pd.read_csv('train.csv')

data = np.array(data)
amount_of_rows, amount_of_features = data.shape
np.random.shuffle(data)  # shuffle before splitting into dev and training sets

data_dev = data[0:1000].T
Y_dev = data_dev[0]
X_dev = data_dev[1:amount_of_features]
X_dev = X_dev / 255.

data_train = data[1000:amount_of_rows].T
Y_train = data_train[0]
X_train = data_train[1:amount_of_features]

X_train = X_train / 255.
_, m_train = X_train.shape


# To get image for test
def getImage(image_name):
    data = asarray(Image.open(image_name))

    data = np.array(data)
    amount_of_rows, amount_of_features = data.shape

    data_train = data
    X_train = data_train[0:amount_of_features]
    X_train = X_train / 255
    result = X_train.flatten()

    arr = []
    for i in result:
        cr = [i]
        arr.append(cr)

    return arr


def init_params():

    # To initiate with random parameters
    """
    W1 = np.random.rand(10, 784) - 0.5
    b1 = np.random.rand(10, 1) - 0.5
    W2 = np.random.rand(10, 10) - 0.5
    b2 = np.random.rand(10, 1) - 0.5
    """

    # To initiate with current parameters
    W1 = np.loadtxt("W1.txt").reshape(10, 784)
    b1 = np.loadtxt("b1.txt").reshape(10, 1)
    W2 = np.loadtxt("W2.txt").reshape(10, 10)
    b2 = np.loadtxt("b2.txt").reshape(10, 1)

    return W1, b1, W2, b2


# ReLU is an activation function being used by the AI to keep the values positive and effective
def ReLU(Z):
    return np.maximum(Z, 0)


# softmax is an activation function being used by the AI to normalize values to a range between 0 -> 1
def softmax(Z):
    A = np.exp(Z) / sum(np.exp(Z))
    return A


# forward_prop using the activation functions and math functions like dot to calculate the output layer
# by doing a forwards propagation on the layers of the AI
def forward_prop(W1, b1, W2, b2, X):
    Z1 = W1.dot(X) + b1
    A1 = ReLU(Z1)
    Z2 = W2.dot(A1) + b2
    A2 = softmax(Z2)
    return Z1, A1, Z2, A2


def ReLU_deriv(Z):
    return Z > 0


def one_hot(Y):
    one_hot_Y = np.zeros((Y.size, Y.max() + 1))
    one_hot_Y[np.arange(Y.size), Y] = 1
    one_hot_Y = one_hot_Y.T
    return one_hot_Y


def backward_prop(Z1, A1, Z2, A2, W1, W2, X, Y):
    one_hot_Y = one_hot(Y)
    dZ2 = A2 - one_hot_Y
    dW2 = 1 / amount_of_rows * dZ2.dot(A1.T)
    db2 = 1 / amount_of_rows * np.sum(dZ2)
    dZ1 = W2.T.dot(dZ2) * ReLU_deriv(Z1)
    dW1 = 1 / amount_of_rows * dZ1.dot(X.T)
    db1 = 1 / amount_of_rows * np.sum(dZ1)
    return dW1, db1, dW2, db2


def update_params(W1, b1, W2, b2, dW1, db1, dW2, db2, learning_rate):
    W1 = W1 - learning_rate * dW1
    b1 = b1 - learning_rate * db1
    W2 = W2 - learning_rate * dW2
    b2 = b2 - learning_rate * db2
    return W1, b1, W2, b2


# get_prediction returns the index of the maximum value in the array by axis=0
def get_prediction(A2):
    return np.argmax(A2, 0)


def get_accuracy(predictions, Y):
    print(predictions, Y)
    return np.sum(predictions == Y) / Y.size


def gradient_descent(X, Y, learning_rate, iterations):
    W1, b1, W2, b2 = init_params()
    for i in range(iterations):
        Z1, A1, Z2, A2 = forward_prop(W1, b1, W2, b2, X)
        dW1, db1, dW2, db2 = backward_prop(Z1, A1, Z2, A2, W1, W2, X, Y)
        W1, b1, W2, b2 = update_params(W1, b1, W2, b2, dW1, db1, dW2, db2, learning_rate)
        if i % 10 == 0:
            print("Iteration: ", i)
            predictions = get_prediction(A2)
            print(get_accuracy(predictions, Y))
    return W1, b1, W2, b2


# make_predictions sends all necessary values to the forward propagation method
def make_predictions(X, W1, b1, W2, b2):
    _, _, _, A2 = forward_prop(W1, b1, W2, b2, X)
    # print(A2)                                 # -> To print the chances of each number in percentage
    predictions = get_prediction(A2)
    return predictions


# Loading AI data
def load_data():
    w1_test = np.loadtxt("W1.txt").reshape(10, 784)
    b1_test = np.loadtxt("b1.txt").reshape(10, 1)
    w2_test = np.loadtxt("W2.txt").reshape(10, 10)
    b2_test = np.loadtxt("b2.txt").reshape(10, 1)
    return w1_test, b1_test, w2_test, b2_test


w1_test, b1_test, w2_test, b2_test = load_data()


def prediction(index, W1, b1, W2, b2):
    current_image = X_train[:, index, None]
    ai_prediction = make_predictions(X_train[:, index, None], W1, b1, W2, b2)
    label = Y_train[index]

    print("Prediction: ", ai_prediction)
    print("Label: ", label)

    current_image = current_image.reshape((28, 28)) * 255
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()


# Testing prediction based on training data
def test_prediction(max_index):
    for i in range(max_index):
        prediction(i, w1_test, b1_test, w2_test, b2_test)
        i += 1


def image_prediction(index, W1, b1, W2, b2):
    current_image = index
    current_image = np.array(current_image).T
    ai_prediction = make_predictions(index, W1, b1, W2, b2)

    print("Prediction: ", ai_prediction)
    print("Label: ", "Image test")

    current_image = current_image.reshape((28, 28)) * 255
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()


# Testing prediction based on image input
def test_image_prediction(image_name):
    image = getImage(image_name)
    image_prediction(image, w1_test, b1_test, w2_test, b1_test)


def max_prediction(index, W1, b1, W2, b2):
    ai_prediction = make_predictions(X_train[:, index, None], W1, b1, W2, b2)
    label = Y_train[index]

    if ai_prediction[0] == label:
        return 0
    else:
        return 1


# Testing big amount of predictions from test data
def test_max_prediction():
    num_of_error = 0
    for i in range(41000):

        # test_prediction(i, W1, b1, W2, b2)
        x = max_prediction(i, w1_test, b1_test, w2_test, b2_test)
        num_of_error += x
        i += 1
    print(num_of_error)


# Saving data trained to a text file
def save_data(W1, b1, W2, b2):

    file = open("W1.txt", "w")
    for row in W1:
        np.savetxt(file, row)
    file.close()

    file = open("W2.txt", "w")
    for row in W2:
        np.savetxt(file, row)
    file.close()

    file = open("b1.txt", "w")
    for row in b1:
        np.savetxt(file, row)
    file.close()

    file = open("b2.txt", "w")
    for row in b2:
        np.savetxt(file, row)
    file.close()


# Train AI with test data and save the result
def train_AI(learning_rate, iterations):
    # learning_rate = 0.20
    # iterations = 1000

    W1, b1, W2, b2 = gradient_descent(X_train, Y_train, learning_rate, iterations)
    save_data(W1, b1, W2, b2)
    # Last module accuracy 94.5%


train_AI(0.1, 100)






