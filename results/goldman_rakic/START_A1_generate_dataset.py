import torch, os
import numpy as np
import matplotlib.pyplot as plt
import torchvision.io
from torchvision.transforms import v2
import cv2


torch.manual_seed(1)

H, W = 1012, 1012

results_path = os.path.join(os.getcwd(), 'generated_dataset')
if not os.path.exists(results_path):
    os.makedirs(results_path)

clean_img_file = os.path.join(results_path, '..', 'PFC_stripes_clean.jpg')

img = torchvision.io.read_image(clean_img_file)

transforms = v2.Compose([
    v2.RandomHorizontalFlip(p=0.5),
    v2.RandomRotation(degrees=(0, 360)),
    v2.RandomCrop(size=(H, W))
])

fig, ax = plt.subplots(1, 1)
for i in np.arange(1500):
    out = transforms(img)
    out = out.cpu().numpy()
    out = np.transpose(out, (1, 2, 0))

    ax.imshow(out)
    ax.set_aspect('equal', 'box')
    ax.axis('off')

    # fig.savefig(os.path.join(results_path, f'img_{i}.png'), bbox_inches='tight', pad_inches=0, dpi=500)

    ax.get_xaxis().set_visible(False)
    ax.get_yaxis().set_visible(False)
    plt.autoscale(tight=True)

    cv2.imwrite(os.path.join(results_path, f'img_{i}.png'), out.squeeze(), [cv2.IMWRITE_JPEG_QUALITY, 100])

    # torchvision.utils.save_image(out, os.path.join(results_path, f'img_{i}.png'))

# plt.show()

