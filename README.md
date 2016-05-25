# Wolfs & Lambs
An implementation of a classic river-crossing puzzle.

## ひつじとおおかみ
ひつじ3匹とおおかみ3匹が小舟で対岸に渡ります。

* 小舟は2匹までしか乗れません。
* どちらの岸も，ひつじの数よりおおかみの数が多くなってはいけません
(食べられてしまいます)。
    * ただし，ひつじが居ない岸におおかみが居るのはかまいません。
* 動物が乗らないと小舟は動きません。

うまくひつじとおおかみを小舟に乗せて，全員対岸に渡らせてください。

### 操作方法
* 岸に居る動物をクリックすると，小舟に乗せることができます。
* 小舟に乗っている動物をクリックすると，小舟から降ろすことができます。
* 小舟の下に現れる矢印をクリックすると，小舟が動き始めます。
    * 小舟が空のときや，どちらかの岸でおおかみの数がひつじの数より多くなるときは，矢印が現れません。
* 左上の「Reset」をクリックすると初期状態に戻ります。
    *  ゲームをクリアした後，もう一度遊ぶときも，Resetをクリックしてください。

## Install
wolf_n_lamb.pde をProcessing開発環境で開き，実行してください。

Processing 3 では，minim ライブラリを手で追加する必要があります (「スケッチ」メニューの「ライブラリをインポート...」を選んでください) 。  
On Processing 3, you have to add the Minim library by yourself (Select "Import Library..." in the "Sketch" menu).

自動求解機能 (Auto mode) を使う場合は，予めディレクトリ code にて ant を実行し，code/Solver.jar を生成してください。

## Credits
* Picture of the lamb & turf:
["Spring Lamb"](http://foter.com/photo/spring-lamb/) by
EssjayNZ / Foter /
[CC BY-NC-SA](http://creativecommons.org/licenses/by-nc-sa/2.0/)
* Picture of the wolf:
["The Wild Side of Yellowstone"](http://foter.com/photo/the-wild-side-of-yellowstone-3/) by
Stuck in Customs / Foter /
[CC BY-NC-SA](http://creativecommons.org/licenses/by-nc-sa/2.0/)
* Sound of chimes:
"Crrect_answer3.mp3" by
[Free Sound Effects](http://taira-komori.jpn.org/freesound.html)
