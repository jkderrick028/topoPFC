# Code documentation for topoPFC project

## Components of analysis

- decode task relevant features
    - does the neural population encode certain task-relevant feature
- tuning profile similarity quantification (Moran's I)
    - what's the spatial scale of the population codes 
- tuning profile similarity visualization (MDS)
    - what's the underlying topography 
- feature representation across tasks
    - does the topography change across tasks (full tuning, left & right info, trial epochs)
    - does the topography change after Ketamine injection 

### project path & environment related
`setProjectPath`: defines the root path of topoPFC project. 
Usage: `projectPath = setProjectPath(); `


### Code structure
```
#   analysis
##  spikes
    ### extractTuningANDresiduals (:v:)
##  moranI

```


### spike data

#### load spike data

##### spikeData  
- rasters [NSP0, NSP1]  [100 x time x trials]
- conditions            [trials x 1]
- trialOutcomes         [trials x 1]
- chanLinearInds        [96 x 1], the linear indices of channels on the array
- collapse units or not

</br>

$\textbf{ODR}$
Buzz 
* 20180305
    * fixation on       (-300ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2400ms)
    * response          (2550ms)

* 20180307
    * fixation on       (-300ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2750ms)
    * response          (3000ms)

* 20180314
    * fixation on       (-300ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (3000ms)
    * response          (3200ms)

* 20180315
    * fixation on       (-300ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (3000ms)
    * response          (3200ms)

Theo
* 20170726
    * fixation on       (-500ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2800-3200ms, variable)
    * response          (3200-3800ms, variable)

* 20170802
    * fixation on       (-500ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2800-3200ms, variable)
    * response          (3200-3800ms, variable)

* 20170810
    * fixation on       (-500ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2450ms)
    * response          (2700ms)

* 20170815
    * fixation on       (-500ms)
    * target on         (0ms)
    * target off        (1000ms)
    * fixation off      (2450ms)
    * response          (2700ms)

$\textbf{KM}$
* cue               (3000ms)
* delay             (2000ms)
* response          (<2000ms)

$\textbf{AL}$
* context onset     (>2000ms    preContextOnset)
* goals onset       (4200ms     context2goal)
* decision onset    (800ms      goal2decision)
* reward            (1200ms     postDecision)

* only Buzz 20171109 uses ChanNum, all the other sessions for Buzz and all the sessions for Theo uses ElecNum.

Buzz
20171109 
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Cyan, S_Green

20171110
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Red, S_Blue

20171111
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Yellow, S_Cyan

20171112
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Green, S_Red

20171121
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Yellow, S_Red

20171123
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Green, S_Yellow

Theo
20170329
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Red, S_Blue

20170330
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Green, S_Yellow
* FixedNovel2: W_Yellow, S_Green

20170331
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Cyan, S_Red

20170401
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Blue, S_Green
* FixedNovel2: W_Green, S_Blue

20170403
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Cyan, S_Yellow
* FixedNovel2: W_Red, S_Green

20170405
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Green, S_Cyan
* FixedNovel2: W_Cyan, S_Green

20170406
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Blue, S_Red
* FixedNovel2: W_Red, S_Blue

20170408
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Cyan, S_Blue
* FixedNovel2: W_Blue, S_Cyan

20170413
* FixedStart & FixedEnd: W_Purple, S_Orange
* FixedNovel: W_Cyan, S_Red
* FixedNovel2: W_Yellow, S_Blue

* I found that the ElecNums in Megan's arrayMap files and Rogelio's ODR data files are different. Need the array map files from Ben to confirm which one is correct. For Buzz, no difference between Megan's and Rogelio's files. 

</br>

#### compute firing rates

### Moran's I analysis


### multidimensional scaling (MDS)


### feature representation across tasks 

