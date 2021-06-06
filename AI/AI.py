import numpy as np
from matplotlib import pyplot as plt
from numpy import asarray
import time
from PIL import Image
import os
import imageio as iio
from skimage import filters
from skimage.color import rgb2gray  # only needed for incorrectly saved images
from skimage.measure import regionprops
import cv2


def save_file():
    # Checking if file is not empty
    printed = 0
    while os.stat("../number.txt").st_size == 0:
        if printed == 0:
            print("File is empty")
            printed = 1
        time.sleep(0.1)

    f = open("../number.txt", "r")  # Reading file

    # Saving the file into the array
    arr = []
    for i in range(0, 12544):
        arr.append(int(f.read(1)))

    arr = np.array(arr)
    arr = arr*255

    # Reshaping an array to a 2d array of pixels
    arr2 = arr.reshape(112, 112)

    # Convert the pixels into an array using numpy
    array = np.array(arr2, dtype=np.uint8)

    # Creating blank image file
    img = Image.new('RGB', (28, 28), color='black')
    img.save('privateImage.png')

    # Use PIL to create an image from the new array of pixels
    new_image = Image.fromarray(array)
    new_image.save('privateImage.png')

    # Resizing the image to 28 by 28 for the AI
    image = Image.open('privateImage.png')
    new_image = image.resize((28, 28))
    new_image.save('privateImage.png')

    # To prevent black image problems
    if sum(arr) == 0:
        return 0
    center_image()


def center_image():
    # Read image
    img = cv2.imread("privateImage.png")

    # finding center of mass of image
    image = rgb2gray(iio.imread("privateImage.png"))
    threshold_value = filters.threshold_otsu(image)
    labeled_foreground = (image > threshold_value).astype(int)
    properties = regionprops(labeled_foreground, image)
    center_of_mass = properties[0].centroid

    # size of the image
    num_rows, num_cols = img.shape[:2]

    # finding how much to move in each direction
    move_x = center_of_mass[1] - num_rows/2
    move_y = center_of_mass[0] - num_rows/2

    # Creating a translation matrix
    translation_matrix = np.float32([[1, 0, -move_x], [0, 1, -move_y]])

    # Image translation
    img_translation = cv2.warpAffine(img, translation_matrix, (num_cols + 0, num_rows + 0))

    # Save image
    cv2.imwrite("privateImage.png", img_translation)

    # Remove the rbg type of image by converting it to grayscale & saving it
    new_image = Image.fromarray(np.array(Image.open('privateImage.png').convert('L')))
    new_image.save('privateImage.png')


def get_image():
    save_file()                   # Saving file in the proper shape needed

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

    current_image = current_image.reshape((28, 28)) * 255
    # Showing image on screen
    plt.gray()
    plt.imshow(current_image, interpolation='nearest')
    plt.show()


# Loading AI data from saved files
w1_test = np.loadtxt("W1.txt").reshape(10, 784)
b1_test = np.loadtxt("b1.txt").reshape(10, 1)
w2_test = np.loadtxt("W2.txt").reshape(10, 10)
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



