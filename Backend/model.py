import numpy as np
import tensorflow as tf
from tensorflow.keras.datasets import mnist
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.utils import to_categorical


# 1. Load MNIST dataset
(x_mnist, y_mnist), (x_test_mnist, y_test_mnist) = mnist.load_data()
x_mnist = x_mnist.reshape(-1, 28, 28, 1).astype('float32') / 255.0
x_test_mnist = x_test_mnist.reshape(-1, 28, 28, 1).astype('float32') / 255.0
y_mnist = to_categorical(y_mnist, 10)
y_test_mnist = to_categorical(y_test_mnist, 10)


print("MNIST loaded:", x_mnist.shape)


# 2. Load your custom handwritten digits
datagen = ImageDataGenerator(rescale=1./255)


custom_data = datagen.flow_from_directory(
   '/home/fleettrack/subhaashree/digit_reco_backend/custom_dataset',      # Change path if needed
   target_size=(28, 28),
   color_mode='grayscale',
   batch_size=10000,         # Load all at once
   class_mode='categorical',
   shuffle=True
)


x_custom, y_custom = next(custom_data)
x_custom = x_custom.reshape(-1, 28, 28, 1)


print("Custom data loaded:", x_custom.shape)


# 3. Combine MNIST + custom data
x_train_combined = np.concatenate([x_mnist, x_custom])
y_train_combined = np.concatenate([y_mnist, y_custom])


print("Combined dataset:", x_train_combined.shape)


# 4. Define the CNN model
model = Sequential([
   Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)),
   MaxPooling2D((2, 2)),
   Conv2D(64, (3, 3), activation='relu'),
   MaxPooling2D((2, 2)),
   Flatten(),
   Dense(128, activation='relu'),
   Dense(10, activation='softmax')
])


model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])


# 5. Train the model
model.fit(x_train_combined, y_train_combined,
         validation_data=(x_test_mnist, y_test_mnist),
         epochs=15,
         batch_size=64)


# 6. Save the trained model
model.save('mnist_plus_custom_model2.h5')
print("✅ Model saved as mnist_plus_custom_model2.h5")
