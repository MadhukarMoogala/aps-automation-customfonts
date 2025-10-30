
;;; Command to create KOREAN_STYLE if not present and substitute all text styles to KOREAN_STYLE
(defun c:SUBST ( / ss i ent entData)
  ;; Create style if it doesn't exist
  (if (not (tblsearch "style" "KOREAN_STYLE"))
    (entmake (list '(0 . "STYLE")		     '(100 . "AcDbSymbolTableRecord")
		 '(100 . "AcDbTextStyleTableRecord")
		 '(2 . "KOREAN_STYLE")	     '(70 . 0)
		 '(40 . 0.0)		     '(41 . 1.0)
		 '(50 . 0.0)		     '(71 . 0)
		 '(42 . 0.09375)	     '(3 . "romans.shx")
		 '(4 . "GHS.shx")
		)
  )   
  )
  ;; Select all text-like entities
  (setq ss (ssget "_X" '((0 . "TEXT,MTEXT,ATTRIB,ATTDEF"))))
  (if ss
    (progn
      (setq i 0)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq entData (entget ent))
        ;; Only substitute if style is different
        (if (not (equal (cdr (assoc 7 entData)) "KOREAN_STYLE"))
          (progn
            (entmod (subst (cons 7 "KOREAN_STYLE") (assoc 7 entData) entData))
            (entupd ent)
          )
        )
        (setq i (1+ i))
      )
    )
  )

  (command "_ZOOM" "E")
  ;; Uncomment below for PDF plot automation
  ;; (command "-PLOT" "Y" "Model"
  ;;           "AutoCAD PDF (Web and Mobile).pc3"
  ;;           "ISO_full_bleed_A3_(420.00_x_297.00_MM)"
  ;;           "M" "L" "N"
  ;;           "Extents"
  ;;           "Fit" "Center" "Y"
  ;;           "monochrome.ctb"
  ;;           "Y" "A" "input.pdf"
  ;;           "N" "Y")

  (princ "\n[Complete: KOREAN_STYLE created and substituted]")
  (princ)
)