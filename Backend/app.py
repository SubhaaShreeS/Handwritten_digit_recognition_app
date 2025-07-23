import cv2
from flask import Flask, request, jsonify
import numpy as np
from PIL import Image, ImageOps
import tensorflow as tf
import os

app = Flask(__name__)

# Load the trained MNIST model (update the filename as needed)
model = tf.keras.models.load_model("mnist_plus_custom_model2.h5")


def preprocess_image(file):
    # Open image in grayscale
    image = Image.open(file).convert("L")

    # Convert to numpy array
    img = np.array(image)

    # Apply threshold to binarize (make background white and digit black)
    _, img = cv2.threshold(img, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # Save for debugging
    Image.fromarray(img).save("1_thresholded.png")

    # Find bounding box of digit
    coords = cv2.findNonZero(img)
    if coords is None:
        raise ValueError("No digit found")

    x, y, w, h = cv2.boundingRect(coords)

    # Crop to digit
    cropped = img[y:y+h, x:x+w]

    # Make square
    side = max(w, h)
    square = np.full((side, side), 0, dtype=np.uint8)
    x_offset = (side - w) // 2
    y_offset = (side - h) // 2
    square[y_offset:y_offset+h, x_offset:x_offset+w] = cropped

    # Resize to 28x28
    resized = cv2.resize(square, (28, 28), interpolation=cv2.INTER_AREA)

    # Save processed image
    Image.fromarray(resized).save("2_final_input.png")

    # Normalize and reshape
    img_array = resized / 255.0
    img_array = img_array.reshape(1, 28, 28, 1)

    return img_array



@app.route("/predict", methods=["POST"])
def predict():
    try:
        if "file" not in request.files:
            return jsonify({"error": "No file uploaded"}), 400

        file = request.files["file"]
        image = preprocess_image(file)  

        prediction = model.predict(image)
        digit = int(np.argmax(prediction))

        return jsonify({"prediction": digit})

    except Exception as e:
        print("🔥 Error:", str(e))
        return jsonify({"error": str(e)}), 500



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9008)
