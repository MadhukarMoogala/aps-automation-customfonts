(defun c:CallPlot ()
  (command "_ZOOM" "E")
  (command "-PLOT" "Y" "Model"
            "AutoCAD PDF (Web and Mobile).pc3"
            "ISO_full_bleed_A3_(420.00_x_297.00_MM)"
            "M" "L" "N"
            "Extents"
            "Fit" "Center" "Y"
            "monochrome.ctb"
            "Y" "A" "input.pdf"
            "N" "Y")
  (princ)
)