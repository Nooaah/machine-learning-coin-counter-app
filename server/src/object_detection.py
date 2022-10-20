import os
import cv2
import numpy as np
import datetime


class object_detection:
    """
    This class contains methods to generate a new picture containing
    the probabilities,and to calculate how many euros are in the picture.
    """

    def __init__(self, UPLOAD_FOLDER, CALCULATED_FOLDER):
        self.UPLOAD_FOLDER = UPLOAD_FOLDER
        self.CALCULATED_FOLDER = CALCULATED_FOLDER

        # Load Yolo (default lines for YOLO)
        self.net = cv2.dnn.readNet(
            "yolov3_training_2400.weights", "yolov3.cfg")
        self.layer_names = self.net.getLayerNames()
        self.output_layers = [self.layer_names[i - 1] for i in self.net.getUnconnectedOutLayers()]

        self.classes = []
        with open("coco.names", "r") as f:
            self.classes = [line.strip() for line in f.readlines()]
        self.colors = np.random.uniform(0, 255, size=(len(self.classes), 3))

    def calculate(self, start_date, alphanumeric_filename):
        """
        The calculate method is the main method of this class,
        it allows to make calculations on the image received
        by the server with the neural network YOLO

        :param start_date: datetime -- Variable to start the execution of the program, from the reception of the request
        :param alphanumeric_filename: str -- Name of the file received by the server in alphanumeric format 
        """

        self.alphanumeric_filename = alphanumeric_filename
        # Loading imported image
        img = cv2.imread(os.path.join(
            self.UPLOAD_FOLDER, self.alphanumeric_filename))

        height, width, channels = img.shape

        # Detecting objects (Deep Neural Network module)
        blob = cv2.dnn.blobFromImage(
            img, 0.00392, (416, 416), (0, 0, 0), True, crop=False)
        self.net.setInput(blob)
        outs = self.net.forward(self.output_layers)

        # Showing informations on the screen
        class_ids = []
        confidences = []
        boxes = []
        for out in outs:
            for detection in out:
                scores = detection[5:]
                class_id = np.argmax(scores)
                confidence = scores[class_id]
                if confidence > 0.5:
                    # Object detected
                    center_x = int(detection[0] * width)
                    center_y = int(detection[1] * height)
                    w = int(detection[2] * width)
                    h = int(detection[3] * height)

                    # Rectangle coordinates
                    x = int(center_x - w / 2)
                    y = int(center_y - h / 2)

                    boxes.append([x, y, w, h])
                    confidences.append(float(confidence))
                    class_ids.append(class_id)

        indexes = cv2.dnn.NMSBoxes(boxes, confidences, 0.5, 0.4)

        self.generate_image_with_probabilities(
            boxes, indexes, class_ids, confidences, img)

        end_date = datetime.datetime.now()

        execution_time = end_date - start_date

        return {
            "calculated_image_path": "http://192.168.1.12:5000/get_image/" + self.alphanumeric_filename,
            "coins_total": round(self.price_counter(boxes, indexes, class_ids), 2),
            "execution_time": str(
                round((execution_time.microseconds/1000000), 3))}

    def generate_image_with_probabilities(self, boxes, indexes, class_ids, confidences, img):
        """
        This method generates the new image from the one received by the server,
        with the coins surrounded, as well as the probability of each
        """

        font = cv2.FONT_HERSHEY_PLAIN
        for i in range(len(boxes)):
            if i in indexes:
                x, y, w, h = boxes[i]
                label = str(self.classes[class_ids[i]])
                color = self.colors[class_ids[i]]
                confidence = str(round(confidences[i] * 100, 2))
                cv2.rectangle(img, (x, y), (x + w, y + h), color, 5)
                cv2.putText(img, label + " (" + confidence + "%)",
                            (x, y - 40), font, 2, color, 3)
        cv2.imwrite(self.CALCULATED_FOLDER + self.alphanumeric_filename, img)

    def price_counter(self, boxes, indexes, class_ids):
        """
        This method allows to count the total in euro of
        the coins present on the photo received by the server
        """

        total = 0.0
        for i in range(len(boxes)):
            label = str(self.classes[class_ids[i]])
            if i in indexes:
                if label == "5 cents":
                    total += 0.05
                elif label == "10 cents":
                    total += 0.1
                elif label == "20 cents":
                    total += 0.2
                elif label == "50 cents":
                    total += 0.5
                elif label == "50 cents":
                    total += 0.5
                elif label == "1 euro":
                    total += 1
                elif label == "2 euros":
                    total += 2
        return total
