import sys
sys.path.append('C:\\users\\yoyoy\\anaconda3\\envs\\rl\\lib\\site-packages')


# In[2]:


import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import h5py

import cv2 
import os
import random
import matplotlib.pyplot as plt
#get_ipython().run_line_magic('matplotlib', 'inline')
import numpy as np

import warnings
warnings.filterwarnings('ignore')


# In[3]:


new_model = keras.models.load_model("FER13_Accuracy94.h5")


# In[5]:


path = "haarcascade_forntalface_default.xml"
font_scale = 1.5
font = cv2.FONT_HERSHEY_PLAIN

#set rectangle on screen to display status
rectangle_bgr = (255,255,255)
img = np.zeros((500,500)) #make black image
text = "Status"
# get width and height of text box
(text_width, text_height) = cv2.getTextSize(text, font, fontScale=font_scale, thickness=2)[0]

# set text position
text_offset_x = 10
text_offset_y = img.shape[0]-25

# coordinates of box
box_coords = ((text_offset_x,text_offset_y), (text_offset_x + text_width + 2, text_offset_y - text_height - 2))
cv2.rectangle(img, box_coords[0], box_coords[1], rectangle_bgr, cv2.FILLED)
cv2.putText(img, text, (text_offset_x,text_offset_y), font, fontScale=font_scale, color=(0,0,0), thickness=2)

# Real Time video starts here
# Open Camera if not open
cap = cv2.VideoCapture(0)
# check if camera is opened correctly
if not cap.isOpened():
    cap = cv2.VideoCapture(0)
if not cap.isOpened():
    raise IOError("Cannot open Camera")
    
while True:
    ret,frame = cap.read()
    #eye_cascade = cv2.CascadeClassifier('haarcascade_eye.xml')
    faceCascade = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    faces = faceCascade.detectMultiScale(gray,1.1,4)
    # print('df')
    # print(len(faces))
    # print(faces)
    if(len(faces) == 0):
        print("Face not detected")
    else:    
        for x,y,w,h in faces:
            roi_gray = gray[y:y+h, x:x+w]
            roi_color = frame[y:y+h, x:x+w]
            cv2.rectangle(frame, (x,y), (x+w,y+h), (0,255,0), 2)
            facess = faceCascade.detectMultiScale(roi_gray)
            if len(facess) == 0:
                print("Face not detected")
                
            else:
                for (ex,ey,ew,eh) in facess:
                    face_roi = roi_color[ey:ey+eh, ex:ex+ew]
                    print(roi_color.shape)
                    print(face_roi.shape)
                    
                    final_image = cv2.resize(face_roi, (224,224))
                    final_image = np.expand_dims(final_image, axis = 0) #need 4th dimension
                    final_image = final_image/255.0
                    
                    font = cv2.FONT_HERSHEY_SIMPLEX
                    
                    pred = new_model.predict(final_image)
                    
                    font_scale = 1.5
                    font = cv2.FONT_HERSHEY_PLAIN
        
                    if (np.argmax(pred) == 0):
                        status = "Angry"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    elif (np.argmax(pred) == 1):
                        status = "Disgust"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    elif (np.argmax(pred) == 2):
                        status = "Fear"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    elif (np.argmax(pred) == 3):
                        status = "Happy"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    elif (np.argmax(pred) == 4):
                        status = "Neutral"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    elif (np.argmax(pred) == 5):
                        status = "Sad"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    else:
                        status = "Surprise"
                        
                        x1,y1,w1,h1 = 0,0,175,75
                        # Draw black background rectangle
                        cv2.rectangle(frame, (x1,x1), (x1+w1, y1+h1), (0,0,0), -1)
                        # Add Text
                        cv2.putText(frame, status, (x1+int(w1/10), y1+int(h1/10)), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
                        
                        cv2.putText(frame, status, (100,150), font, 3, (0,255,0), 2, cv2.LINE_4)
                        
                        cv2.rectangle(frame, (x,y), (x+w, y+h), (0,255,0))
                        
                    
        cv2.imshow('Face Emotion Recognition', frame)
                    
        # Handle Exit
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
                        
        #break

cap.release()
cv2.destroyAllWindows()





