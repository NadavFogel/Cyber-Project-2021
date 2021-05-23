from PIL import Image
import numpy as np
import os
import time


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

