from PIL import Image
import numpy as np
import os
import time
import imageio as iio
from skimage import filters
from skimage.color import rgb2gray  # only needed for incorrectly saved images
from skimage.measure import regionprops
import cv2


def save_file():
    # Checking if file is not empty
    while os.stat("../number.txt").st_size == 0:
        print("File is empty")
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

    # Use PIL to create an image from the new array of pixels
    new_image = Image.fromarray(array)
    new_image.save('privateImage.png')

    # Resizing the image to 28 by 28 for the AI
    image = Image.open('privateImage.png')
    new_image = image.resize((28, 28))
    new_image.save('privateImage.png')
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