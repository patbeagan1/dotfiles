#!python3

import sys
import cv2
import numpy as np
import time

"""
Use code to merge the frames: 
You can also merge frames together using code, particularly in the context of computer vision and image processing. 
This involves identifying common features in each frame and using them to align and blend the images.

a. Load the frames into the code as image arrays or matrices.
b. Identify common features in each frame using feature detection algorithms such as SIFT or SURF.
c. Use feature matching algorithms such as RANSAC or homography to align the frames together.
d. Blend the frames together using techniques such as averaging or weighted averaging to create a seamless, large image.
"""

# # Load the video
# video = cv2.VideoCapture('panning_video.mp4')

# # Set the frame number to extract
# frame_num = 100

# # Extract the frame
# video.set(cv2.CAP_PROP_POS_FRAMES, frame_num)
# ret, frame = video.read()

# # Save the frame as an image
# cv2.imwrite('panning_frame.jpg', frame)


def main():
    # Open the video file
    # cap = cv2.VideoCapture("my-video.webm")

    images = []

    # # Loop through all the frames
    # while cap.isOpened():
    #     # Read a frame from the video
    #     ret, frame = cap.read()

    #     # If the frame was read successfully
    #     if ret == True:
    #         # Do something with the frame here
    #         # For example, display the frame in a window
    #         cv2.imshow("Frame", frame)

    #         images.append(frame)

    #         # Wait for a key press to exit
    #         if cv2.waitKey(25) & 0xFF == ord("q"):
    #             break
    #     # If the frame could not be read
    #     else:
    #         break

    # cap.release()

    for i in sys.argv:
        if i == sys.argv[0]:
            continue
        out = cv2.imread(i)
        out = cv2.transpose(out)
        out = cv2.flip(out, flipCode=0)
        images.append(out)

    stitchy = cv2.Stitcher.create()
    (dummy, output) = stitchy.stitch(images)

    print(dummy)

    if dummy != cv2.STITCHER_OK:
        # checking if the stitching procedure is successful
        # .stitch() function returns a true value if stitching is
        # done successfully
        print("stitching ain't successful")
    else:
        print("Your Panorama is ready!!!")

    cv2.imwrite(str(time.time()) + ".jpg", output)

    # final output
    cv2.imshow("final result", output)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


if __name__ == "__main__":
    main()