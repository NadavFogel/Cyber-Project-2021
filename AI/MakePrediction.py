import numpy as np
from matplotlib import pyplot as plt
from numpy import asarray
from PIL import Image
import time
# Execute save and resize code
import SaveAndResize
import keyboard


def get_image():
    SaveAndResize.save_file()                   # Saving file in the proper shape needed

    # Transferring the image into an array
    data = asarray(Image.open('privateImage.png'))
    data = np.array(data)
    amount_of_rows, amount_of_features = data.shape

    X_image = data[0:amount_of_features]
    X_image = X_image / 255                     # Getting a black & white image
    result = X_image.flatten()                  # Transforming a 2d array into a 1d

    # Creating an array of the pixels of the image
    arr = []
    for i in result:
        cr = [i]
        arr.append(cr)

    return arr


# ReLU is an activation function being used by the AI to keep the values positive and effective
def ReLU(Z):
    return np.maximum(Z, 0)


# softmax is an activation function being used by the AI to normalize values to a range between 0 -> 1
def softmax(Z):
    A = np.exp(Z) / sum(np.exp(Z))
    return A


# get_prediction returns the index of the maximum value in the array by axis=0
def get_prediction(A2):
    return np.argmax(A2, 0)


# forward_prop using the activation functions and math functions like dot to calculate the output layer
# by doing a forwards propagation on the layers of the AI
def forward_prop(W1, b1, W2, b2, X):
    Z1 = W1.dot(X) + b1
    A1 = ReLU(Z1)
    Z2 = W2.dot(A1) + b2
    A2 = softmax(Z2)
    return Z1, A1, Z2, A2


# make_predictions sends all necessary values to the forward propagation method
def make_predictions(X, W1, b1, W2, b2):
    _, _, _, A2 = forward_prop(W1, b1, W2, b2, X)
    # print(A2)                                 # -> To print the chances of each number in percentage
    predictions = get_prediction(A2)
    return predictions


def send_prediction(index, W1, b1, W2, b2):
    current_image = index
    current_image = np.array(current_image).T
    prediction = make_predictions(index, W1, b1, W2, b2)

    # print("Label: ", "Image")
    # print("Prediction: ", prediction)         # -> To print prediction on current image

    # Sends prediction to assembly by specific file
    f = open("../result.txt", "w")
    f.write(str(prediction[0]))
    f.close()

    # Display image on screen
    '''
    current_image = current_image.reshape((28, 28)) * 255
    # Showing image on screen
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()
    '''


# Loading AI data from saved files
w1_test = np.loadtxt("W1.txt").reshape(10, 784)
w2_test = np.loadtxt("W2.txt").reshape(10, 10)
b1_test = np.loadtxt("b1.txt").reshape(10, 1)
b2_test = np.loadtxt("b2.txt").reshape(10, 1)


while True:
    print("Processing data...")
    image = get_image()                         # Getting the image
    # Testing image with AI + Printing prediction and changes
    send_prediction(image, w1_test, b1_test, w2_test, b1_test)

    # Clearing number file
    file = open("../number.txt", "r+")
    file.truncate(0)
    file.close()

    time.sleep(0.1)



