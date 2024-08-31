import torch, os
import numpy as np
import matplotlib.pyplot as plt
import torchvision.io
from torchvision.transforms import v2
import cv2


torch.manual_seed(1)

H, W = 1012, 1012

# resizes = [0.4, 0.6, 0.8, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
resizes = [0.5]

for newSize in resizes:
    results_path = os.path.join(os.getcwd(), f'generated_dataset_{newSize}')
    if not os.path.exists(results_path):
        os.makedirs(results_path)

    clean_img_file = os.path.join(results_path, '..', 'PFC_stripes_clean.jpg')
    img = torchvision.io.read_image(clean_img_file)

    transforms = v2.Compose([
        v2.Grayscale(1), 
        v2.Resize(size=[np.ceil(newSize*img.size()[1]).astype(int), np.ceil(newSize*img.size()[2]).astype(int)]),
        v2.RandomHorizontalFlip(p=0.5),
        v2.RandomRotation(degrees=(0, 360)),
        v2.RandomCrop(size=(H, W))
    ])

    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=None)
    for i in np.arange(300):
        out = transforms(img)
        out = out.cpu().numpy()

        ax.imshow(out.squeeze(), cmap='gray', vmin=0, vmax=255)
        ax.set_aspect('equal', 'box')
        ax.axis('off')

        ax.get_xaxis().set_visible(False)
        ax.get_yaxis().set_visible(False)
        plt.autoscale(tight=True)

        cv2.imwrite(os.path.join(results_path, f'img_{i}.png'), out.squeeze(), [cv2.IMWRITE_JPEG_QUALITY, 100])

