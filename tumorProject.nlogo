extensions [ rnd ] ; Extension needed to zip the list of divide outcomes together.
globals [ cCount outcome divide-list  mCount oCount interprob increasing-prob sCount ]
turtles-own [ metastatic? div-prob met-prob seed-prob CAF?]
patches-own [ organ? ]
to setup
  clear-all
  ask patches [ set pcolor white ] ; sets the background to white
  set-default-shape turtles "dot"
  create-turtles 1 [
    set color red
    setxy (min-pxcor / 2) 0
    set size 3
    set div-prob initial-divide-probability
    set seed-prob seed-probability
    set met-prob beginning-metastasis-probability
  ]
   ; sets the middle patch to red, signifies the first cancerous cell of the tumor.
  ask one-of patches with [ distance patch 25 0 < 1 ] [ set pcolor green ]
  set oCount 1 ; Number of organ cells, this is only to help with growing thresholds.
  set cCount 1 ; Counts the number of cancerous cells, starts at one to count the first cancer cell.
  set mCount 0 ; Counts the number of metastasized cells.
  set divide-list[] ; Divide list that will be used to zip the probabilities of cells dividing to the two outcomes.
  set organ-size 500
  set increasing-prob 0
  reset-ticks
end

to go ; Asks the program to begin dividing and then to check for metastasis.
  while [oCount < organ-size] [ grow-organ ]
  divide
  if mCount < 1
  [
    metastasize
  ]
  CAF
  update-probability
  ask turtles-on patches with [ pcolor = green ] [
    set sCount count turtles-on patches with [ pcolor = green ] - count turtles with [ color = blue ] in-radius 1
  ]
  tick
end

to grow-organ ; Grows an organ within the threshold number of cells for the cancer to spread to, stops growing automatically after the threshold has been reached.
    ask patches with [ pcolor = green ] [
    let covered count neighbors with [ pcolor = white ]
    if covered > 0 and oCount + 1 <= organ-size [
      ask one-of neighbors with [ pcolor = white ] [
        set pcolor green
        set organ? true
        set oCount count patches with [ pcolor = green ]
      ]
    ]
  ]
  if oCount + 1 = organ-size
  [
    stop
  ]
end

to divide ; Asks cancer cells to spread to neighbor patches with the color white.
  if cCount >= 1 [
    ask one-of turtles with [ color = red ] [
      if pick div-prob [
        hatch 1 [ rt random-float 360 fd .5]
        set cCount count turtles with [ color = red ] - sCount
      ]
    ]
  ]
end

to seed ; The probability of whether or not the cells will "seed" and stick when they metastasize
   if pick seed-prob = false and (count neighbors with [ pcolor = green ] > 0) [
     set color orange
     set color black
     die
     stop
  ]
end

to metastasize ; Handles the probability that the cancer with metastasize and spread.
  let m 0
  if m = 0 [
    ask one-of turtles with [ color = red ] [
      if pick met-prob [ set metastatic? true ]
      set m count turtles with [ metastatic? = true ]
      hatch 1
    ]

  ]
  if m >= 1 [
    ask one-of turtles with [ metastatic? = true ]
    [
      move-to one-of patches with [ pcolor = green ]
      seed
      set mCount mCount + 1
    ]
  ]
end

to CAF ; creates Cancer associated fibroblasts that modify the probabilities of each of the cells they interact with
  let ran-x 0
  let ran-y 0
  if CAFs-on and cCount >= 1 [
    ask one-of turtles with [ color = red ] [
      if pick div-prob [
        set ran-x pxcor
        set ran-y pycor
        hatch 1 [
          set color blue
          set size 1
          setxy ran-x ran-y
          set CAF? true
          ask turtles with [ color = red ] in-radius 1 [ update-probability ]
        ]
      ]
    ]

  ]
end

to update-probability
  let update-list [ "div" "met" "seed"]
  ask one-of turtles with [ color = red ] [
    let r random 3
    if r = 1 [
      let x one-of update-list
      if x = "div" [
        set div-prob div-prob + increasing-probability div-prob
      ]
      if x = "met" [
        set met-prob met-prob + increasing-probability met-prob
      ]
      if x = "seed"
      [
        set seed-prob seed-prob + increasing-probability seed-prob
      ]
    ]
    if r = 2
    [
      let x n-of 2 update-list
      if x = ["div" "met"] or x = ["met" "div"] [
        set div-prob div-prob + increasing-probability div-prob
        set met-prob met-prob + increasing-probability met-prob
      ]
      if x = ["div" "seed"] or x = ["seed" "div"] [
        set div-prob div-prob + increasing-probability div-prob
        set seed-prob seed-prob + increasing-probability seed-prob
      ]
      if x = ["met" "seed"] or x = ["seed" "met"] [
        set seed-prob seed-prob + increasing-probability seed-prob
        set met-prob met-prob + increasing-probability met-prob
      ]
    ]
    if r = 3
    [
      set div-prob div-prob + increasing-probability div-prob
      set seed-prob seed-prob + increasing-probability seed-prob
      set met-prob met-prob + increasing-probability met-prob
    ]
  ]
end

to-report pick [passed]; Zips the lists together to allow for a pseudorandom probability that the cell will divide based on user slider input
  set interprob passed
  ifelse interprob > 0 and interprob <= 1.00 [
    set divide-list list (interprob) (1.0 - interprob)
    set outcome [ true false ]
    report first rnd:weighted-one-of-list (map list outcome divide-list) last
  ]
  [
    ifelse interprob > 1.00
    [
      report true
    ]
    [
      report false
    ]
  ]
end

to-report increasing-probability [ old-prob ]
  let new-prob 0
  if old-prob < 1.00
  [
    set new-prob random-float .001
  ]
  report new-prob
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
713
514
-1
-1
5.0
1
10
1
1
1
0
1
1
1
-49
49
-49
49
0
0
1
ticks
60.0

BUTTON
73
112
133
145
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
70
241
133
274
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
48
317
166
362
Original Tumor Size
cCount
17
1
11

PLOT
0
426
160
578
Proliferation
time
cancerous cells
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"initial proliferation" 1.0 0 -955883 true "" "plot cCount"
"metastasis proliferation" 1.0 0 -2674135 true "" "plot sCount"

SLIDER
15
593
196
626
initial-divide-probability
initial-divide-probability
0
1
0.85
.05
1
NIL
HORIZONTAL

SLIDER
15
644
248
677
beginning-metastasis-probability
beginning-metastasis-probability
0
1
0.25
.05
1
NIL
HORIZONTAL

INPUTBOX
66
163
137
223
organ-size
500.0
1
0
Number

SLIDER
210
594
342
627
seed-probability
seed-probability
0
1
0.85
.05
1
NIL
HORIZONTAL

SWITCH
37
723
141
756
CAFS-on
CAFS-on
1
1
-1000

MONITOR
43
375
164
420
Size of organ tumor
sCount
17
1
11

@#$#@#$#@
## WHAT IS IT?

This model is meant to represent a tumor growing within the human body and count the number of cells over time, the cell then becomes metastatic after it reaches a certain point. The tumor cells will then have a probability of seeding to an organ shown in green and begin growing there until a threshold is reached where the tumor will stop growing and the organ will be considered a failing organ. 

## HOW IT WORKS
The model asks patches to set the color of neighbor patches to red as the tumor spreads through the body. After a user set tumor size, the cell then becomes metastatic. Tumor cells will then have an increasing seeding probability over time that adds to the intial probability set by the user. The user also has control over the initial growth size of the tumor itself and 

## HOW TO USE IT

The setup button resets the ticks of the model and sets one cell in the window to be a cancer cell. Press go to step through and watch the tumor grow. The model will keep track of the number of cancerous cells and plot the amount of cancerous cells over time.

## THINGS TO NOTICE

N/A

## THINGS TO TRY

N/A

## EXTENDING THE MODEL

This model can be futher used to model other aspects that affect a tumor over time.

## NETLOGO FEATURES

N/A

## RELATED MODELS

The tumor model found in the models library

## CREDITS AND REFERENCES

N/A
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2500"/>
    <exitCondition>sCount = 1</exitCondition>
    <metric>count turtles with [ color = red ]</metric>
    <metric>count turtles with [ color = blue ]</metric>
    <steppedValueSet variable="seed-probability" first="0.1" step="0.25" last="1"/>
    <steppedValueSet variable="initial-divide-probability" first="0.1" step="0.25" last="1"/>
    <enumeratedValueSet variable="CAFS-on">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="beginning-metastasis-probability" first="0.25" step="0.25" last="1"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
