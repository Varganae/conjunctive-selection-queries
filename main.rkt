#lang r7rs

(import (prefix (a-d disk config) disk:)
        (prefix (a-d disk file-system) fs:)
        (prefix (a-d db database) db:)
        (scheme base)
        (scheme write))

;Create a new disk and format it
(define my-disk (disk:new "HardDisk"))
(fs:format! my-disk)

;Create a schema for moons
(define manenschema  '((string  9) ; naam maan
                       (string  9) ; naam planeet
                       (natural 2) ; middellijn
                       (natural 2) ; ontdekjaar
                       (string 10) ; ontdekker
                       ))

; Name your attributes
(define :naam:       0)
(define :planeet:    1)
(define :middellijn: 2)
(define :ontdekjaar: 3)
(define :ontdekker:  4)

;Create a list of moon records
(define manen-rcrds
  (list (list "Maan"      "Aarde"    3476    0 "")
        (list "Phobos"    "Mars"       22 1877 "Hall")
        (list "Deimos"    "Mars"        8 1610 "Hall")
        (list "Io"        "Jupiter"  3550 1610 "Galilei")
        (list "Europa"    "Jupiter"  3100 1610 "Galilei")
        (list "Ganymedes" "Jupiter"  5600 1610 "Galilei")
        (list "Callisto"  "Jupiter"  5050 1610 "Galilei")
        (list "Mimas"     "Saturnus"  520 1789 "Herschel")
        (list "Enceladus" "Saturnus"  600 1789 "Herschel")
        (list "Tethys"    "Saturnus" 1200 1684 "Cassini")
        (list "Dione"     "Saturnus" 1300 1684 "Cassini")
        (list "Rhea"      "Saturnus" 1300 1672 "Cassini")
        (list "Titan"     "Saturnus" 4950 1655 "Huygens")
        (list "Hyperion"  "Saturnus"  400 1848 "Bond")
        (list "Japetus"   "Saturnus" 1200 1671 "Cassini")
        (list "Phoebe"    "Saturnus"  300 1898 "Pickering")
        (list "Janus"     "Saturnus"  350 1966 "Dolfus")
        (list "Ariel"     "Uranus"    600 1851 "Lassell")
        (list "Umbriel"   "Uranus"    400 1851 "Lassell")
        (list "Titania"   "Uranus"   1000 1787 "Herschel")
        (list "Oberon"    "Uranus"    800 1787 "Herschel")
        (list "Miranda"   "Uranus"    100 1948 "Kuiper")
        (list "Triton"    "Neptunus" 4000 1846 "Lassell")
        (list "Nereide"   "Neptunus"  300 1949 "Kuiper")))

; Define a new database
(define zonnestelsel (db:new my-disk "zonnestelsel"))

; Create a new table in the database
(define manen (db:create-table zonnestelsel "manen" manenschema))

; Insert a list of records in a table
(define (insert-records db table records)
  (cond ((null? records) 'done)
        (else
         (db:insert-into-table! db table (car records))
         (insert-records db table (cdr records)))))

; Fill table in db and print to show
(insert-records zonnestelsel manen manen-rcrds)
(db:print-table zonnestelsel manen)
(newline)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; TEST YOUR SOLUTION BELOW ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "SELECT * FROM manen WHERE :ontdekker: = 'Cassini' AND :ontdekjaar: = 1684;\n")                                                 
(display (db:select-from/eq-and zonnestelsel manen `((,:ontdekker: "Cassini")
                                                     (,:ontdekjaar: 1684))))
(newline)

(define resultaat
  (db:select-from/eq-and+ zonnestelsel manen
                          `((,:ontdekker: "Cassini")
                            (,:ontdekjaar: 1684))))
(display (db:table->list resultaat))


(disk:unmount my-disk)