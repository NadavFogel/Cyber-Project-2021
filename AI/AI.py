import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from numpy import asarray
from PIL import Image

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


def getImage():
    data = asarray(Image.open('test.png'))

    data = np.array(data)
    amount_of_rows, amount_of_features = data.shape

    data_train = data
    X_train = data_train[0:amount_of_features]
    # print(amount_of_features)
    X_train = X_train / 255
    result = X_train.flatten()


    arr = []
    for i in result:
        cr = [i]
        arr.append(cr)

    return arr


def init_params():
    W1 = np.random.rand(10, 784) - 0.5
    b1 = np.random.rand(10, 1) - 0.5
    W2 = np.random.rand(10, 10) - 0.5
    b2 = np.random.rand(10, 1) - 0.5
    return W1, b1, W2, b2


def ReLU(Z):
    return np.maximum(Z, 0)


def softmax(Z):
    A = np.exp(Z) / sum(np.exp(Z))
    return A


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


def get_predictions(A2):
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
            predictions = get_predictions(A2)
            print(get_accuracy(predictions, Y))
    return W1, b1, W2, b2


learning_rate = 0.20
iterations = 1000
# W1, b1, W2, b2 = gradient_descent(X_train, Y_train, learning_rate, iterations)
# module accuracy 94.5%


def make_predictions(X, W1, b1, W2, b2):
    _, _, _, A2 = forward_prop(W1, b1, W2, b2, X)
    print(A2)
    predictions = get_predictions(A2)
    return predictions


def test_prediction(index, W1, b1, W2, b2):
    current_image = X_train[:, index, None]
    prediction = make_predictions(X_train[:, index, None], W1, b1, W2, b2)
    label = Y_train[index]

    print("Prediction: ", prediction)
    print("Label: ", label)

    current_image = current_image.reshape((28, 28)) * 255
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()


def test_prediction2(index, W1, b1, W2, b2):
    current_image = index
    print(current_image)
    current_image = np.array(current_image).T
    prediction = make_predictions(index, W1, b1, W2, b2)
    label = "test"

    print("Prediction: ", prediction)
    print("Label: ", label)

    # print("------------")
    # print(current_image)

    current_image = current_image.reshape((28, 28)) * 255
    print("------------")
    # print(current_image)
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()


def test_prediction3(index, W1, b1, W2, b2):
    current_image = X_train[:, index, None]
    prediction = make_predictions(X_train[:, index, None], W1, b1, W2, b2)
    label = Y_train[index]

    print("Prediction: ", prediction)
    print("Label: ", label)

    if prediction[0] == label:
        return 0
    else:
        print("--------------Error--------------")
        return 1


w1_test = np.loadtxt("W1.txt").reshape(10, 784)
w2_test = np.loadtxt("W2.txt").reshape(10, 10)
b1_test = np.loadtxt("b1.txt").reshape(10, 1)
b2_test = np.loadtxt("b2.txt").reshape(10, 1)


# print(two)
# test_prediction2(two, w1_test, b1_test, w2_test, b1_test)

test = getImage()
test_prediction2(test, w1_test, b1_test, w2_test, b1_test)

'''
for i in range(0):
    # test_prediction(i, W1, b1, W2, b2)
    test_prediction(i, w1_test, b1_test, w2_test, b2_test)
    i += 1
'''

# num_of_error = 0
# for i in range(41000):
#
#     # test_prediction(i, W1, b1, W2, b2)
#     x = test_prediction3(i, w1_test, b1_test, w2_test, b2_test)
#     num_of_error += x
#     i += 1
# print(num_of_error)

'''
a_file = open("W1.txt", "w")
for row in W1:
    np.savetxt(a_file, row)
a_file.close()

original_array = np.loadtxt("W1.txt").reshape(10, 784)
print("----")
print(original_array)


a_file = open("W2.txt", "w")
for row in W2:
    np.savetxt(a_file, row)
a_file.close()

original_array = np.loadtxt("W2.txt").reshape(10, 10)
print("----")
print(original_array)


a_file = open("b1.txt", "w")
for row in b1:
    np.savetxt(a_file, row)
a_file.close()

original_array = np.loadtxt("b1.txt").reshape(10, 1)
print("----")
print(original_array)

a_file = open("b2.txt", "w")
for row in b1:
    np.savetxt(a_file, row)
a_file.close()

original_array = np.loadtxt("b2.txt").reshape(10, 1)
print("----")
print(original_array)
'''

'''
print("-----")
print(W1)
print("-----")
print(W2)
print("-----")
print(b1)
print("-----")
print(b2)
'''