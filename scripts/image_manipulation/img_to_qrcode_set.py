import numpy as np
from PIL import Image
import qrcode
from io import BytesIO
import base64
import argparse

def image_to_data_uri(img):
    buffered = BytesIO()
    img.save(buffered, format="PNG")
    return f"data:image/png;base64,{base64.b64encode(buffered.getvalue()).decode()}"

def divide_image(image_path, section_size):
    img = Image.open(image_path)
    img_width, img_height = img.size

    sections = []
    for y in range(0, img_height, section_size):
        for x in range(0, img_width, section_size):
            box = (x, y, x + section_size, y + section_size)
            section = img.crop(box)
            sections.append(section)
    
    return sections

def create_qr_codes(sections):
    qr_images = []
    for section in sections:
        data_uri = image_to_data_uri(section)
        qr = qrcode.QRCode(version=1, box_size=10, border=5)
        qr.add_data(data_uri)
        qr.make(fit=True)
        qr_img = qr.make_image(fill='black', back_color='white')
        qr_images.append(qr_img)
    
    return qr_images

def montage_with_qr(sections, qr_images, section_size):
    num_sections = len(sections)
    img_width = section_size * 2
    montage_width = int(np.ceil(np.sqrt(num_sections)))
    montage_height = int(np.ceil(num_sections / montage_width))
    montage_img = Image.new('RGB', (montage_width * img_width, montage_height * section_size))

    for i, (section, qr_img) in enumerate(zip(sections, qr_images)):
        x = (i % montage_width) * img_width
        y = (i // montage_width) * section_size
        montage_img.paste(section, (x, y))
        montage_img.paste(qr_img.resize((section_size, section_size)), (x + section_size, y))

    return montage_img

def main(image_path, output_path):
    section_size = 50
    sections = divide_image(image_path, section_size)
    qr_images = create_qr_codes(sections)
    montage_img = montage_with_qr(sections, qr_images, section_size)
    montage_img.save(output_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Create a montage of image sections and their QR codes.")
    parser.add_argument("image_path", help="Path to the input image")
    parser.add_argument("output_path", help="Path for saving the output montage")
    args = parser.parse_args()

    main(args.image_path, args.output_path)
