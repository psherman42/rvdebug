#============= jedec-jep106-bank1.tcl =================
# 
#  2023-06-13  pds   initial cut

# EXAMPLE:
#  mfrid = (jep106bank % 16) << 7) | jep106line
#  mfrname = [lindex $[lindex $::JEDEC_JEP106 $jep106bank] $jep106line]  ;# 3NF table look-up


# JEP106BG, rev. JEP106BF.01, May 2023, Page 29
# mfr id has 15 banks, starting with bank 1
# each bank has 126 lines, and starts with line 1
# thus, a total of 1,905 devices are supported by JEDEC JEP

set JEDEC_JEP106_BANK1  [list 0 \
  "AMD"                               \
   ...                                \
]

set JEDEC_JEP106_BANK2  [list 1 \
  "Cirrus Logic"                      \
   ...                                \
]

set JEDEC_JEP106_BANK3  [list 2 \
  "Camintonn Corporation"             \
   ...                                \
]

set JEDEC_JEP106_BANK4  [list 3 \
  "Solectron"                         \
   ...                                \
]

set JEDEC_JEP106_BANK5  [list 4 \
  "T-RAM Incorporated"                \
   ...                                \
]

set JEDEC_JEP106_BANK6  [list 5 \
  "Specular Networks"                 \
   ...                                \
]

set JEDEC_JEP106_BANK7  [list 6 \
  "MOVEKING"                          \
   ...                                \
]

set JEDEC_JEP106_BANK8  [list 7 \
  "Siklu Communication Ltd"           \
   ...                                \
]

set JEDEC_JEP106_BANK9  [list 8 \
  "3D PLUS"                           \
   ...                                \
]

set JEDEC_JEP106_BANK10 [list 9 \
  "Weltronics Co LTD"                 \
  "VMware Inc"                        \
  "Hewlett Packard Enterprise"        \
  "INTENSO"                           \
  "Puya Semiconductor"                \
  "MEMORFI"                           \
  "MSC Technologies GmbH"             \
  "Txrui"                             \
  "SiFive Inc"                        \
  "Spreadtrum Communications"         \
  ...                                 \
]

set JEDEC_JEP106_BANK11 [list 10 \
  "Foerd Technology Co Ltd"           \
    ...                               \
]

set JEDEC_JEP106_BANK12 [list 11 \
  "ABIT Electronics (Shenzhen) Co Ltd" \
   ...                                 \
]

set JEDEC_JEP106_BANK13 [list 12 \
  "Beijing Haawking Technology Co Ltd" \
  "Open HW Group"                      \
     ...                               \
]

set JEDEC_JEP106_BANK14 [list 13 \
  "TECOTON"                            \
   ...                                 \
]

set JEDEC_JEP106_BANK15 [list 14 \
  "Kalray SA"                          \
   ...                                 \
]
