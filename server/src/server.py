from flask import Flask
from flask import send_file
from flask import request
from flask import flash
from flask import redirect
import os
import datetime
import random
from object_detection import object_detection

app = Flask(__name__)
UPLOAD_FOLDER = "files_reception/"
CALCULATED_FOLDER = "calculated_images/"

def alphanumeric(number):
    """
    This function allows to generate an alphanumeric text

    :param number: int -- Number of characters in the expected text
    :return: str -- Text of *number* alphanumeric characters 
    """
    return ''.join(random.choice('0123456789ABCDEF') for i in range(number))


@app.route('/send_image', methods=["POST"])
def send_image():
    """
    This method is the main method, it is called when the server receives a request.
    The method calls the object_detection class in order to analyze and make calculations on the received image.

    :return: json -- { calculated_image_path, coins_total, execution_time }
    """
    # Start the timer to get the execution time at the end
    start_date = datetime.datetime.now()
    print(start_date)

    # Obtenir le fichier reçu de la requête POST
    if request.method == "POST":
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        print(file.filename)
        alphanumeric_filename = alphanumeric(8) + ".jpg"
        print(alphanumeric_filename)
        file.save(os.path.join(UPLOAD_FOLDER, alphanumeric_filename))
        return object_detection(UPLOAD_FOLDER, CALCULATED_FOLDER).calculate(start_date, alphanumeric_filename)


@app.route('/get_image/<filename>')
def get_image(filename):
    print(filename)
    return send_file("calculated_images/" + filename, mimetype='image/jpg')


@app.route('/bonjour/')
def bonjour():
    """
    This route only allows you to test that the server
    is active at the address: http://0.0.0.0:5000/bonjour
    """
    return 'Hello World\n'


if __name__ == "__main__":
    app.url_map.strict_slashes = False
    app.config['MAX_CONTENT_LENGTH'] = 200 * 1024 * 1024
    app.run(host="0.0.0.0", port=5000)
