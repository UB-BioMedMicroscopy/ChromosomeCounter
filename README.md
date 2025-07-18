# 🧬 Semi-Automated Chromosome Counting Macro for Fiji/ImageJ

This Fiji/ImageJ (version 1.54p) macro provides a semi-automated pipeline to efficiently count chromosomes from microscopy image datasets (.lif files). It combines manual ROI selection with automated image processing and segmentation, enabling high-throughput and accurate chromosome quantification.

---

## ⚙️ How it works

- **Batch processing:** Opens all `.lif` image files in a user-selected folder and processes each series within them.
- **Manual ROI selection:** The user selects a rectangular region containing the chromosome spread.
- **Preprocessing:**  
  - Background subtraction (rolling ball radius 50) to reduce noise.  
  - Image duplication for parallel processing steps.
- **Segmentation:**  
  - One copy is Gaussian blurred (sigma=1) and subjected to "Find Maxima" (prominence=180) to detect chromosome boundaries.  
  - The other copy undergoes automatic Otsu thresholding (dark background) to create a binary mask.
- **Combination:** The two processed images are combined with an image calculator (min operation) to isolate individual chromosomes.
- **Particle analysis:** Detects and counts chromosomes (size 0–1000 pixels), storing ROIs in the ROI Manager.
- **User validation:** Displays chromosome count and allows manual correction; user can add comments.
- **Results:** Saves a tab-delimited text file with image name, chromosome count, and comments for each image series.

---

## 🖥️ Requirements

- Fiji/ImageJ version 1.54p with Bio-Formats plugin  
- `.lif` image files containing multi-series microscopy data

---

## 🚀 Usage

1. Run the macro in Fiji/ImageJ version 1.54p.  
2. Select the folder containing `.lif` files.  
3. For each image series, select the chromosome region manually.  
4. Review the segmented chromosomes and adjust the count if necessary.  
5. Add optional comments for each image.  
6. Results are automatically saved in a `Results` subfolder within the selected directory.

---

## 📁 Input / Output

- **Input:** Folder with `.lif` microscopy image files  
- **Output:**  
  - Text files summarizing chromosome counts and comments per image series  
  - ROIs saved in the ROI Manager during processing (optional)

---

## 📚 Citation

If you use this macro in your research, please us.

---

## 🙌 Contact information

Gemma Martin (gemmamartin@ub.edu), Maria Calvo (mariacalvo@ub.edu)
Advanced Optical Microscopy Unit
Scientific and Technological Centers (CCiTUB). Clinic Medicine Campus
UNIVERSITY OF BARCELONA
C/ Casanova 143
Barcelona 08036
Tel: 34 934037159
