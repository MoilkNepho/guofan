#!/bin/sh

# 统计耗时
starttime=$(date +%s)

# 参数处理
if [ $# -eq 0 ];
then
    input='曾国藩全集.epub'
else
    input=$1
fi

# 文件是否存在
if [ ! -f "$input" ];
then
    echo "文件 $input 不存在！"
    echo "使用方式：./main.sh [<目录>/曾国藩全集.epub]"
    exit 1
fi

echo "开始解压.."
unzip -q '曾国藩全集.epub' -d .tmp/
if [[ $? -ne 0 ]];
then
    echo '解压失败！'
    exit 1
else
    echo "解压完毕"
fi

# 拷贝出当前卷的 html
function cp_html(){
    s=$1
    e=$2
    for x in $(seq -f "%04g" $s $e)
    do
        cp html_db/part${x}* text/
    done
}

# 拷贝出当前卷的图片
function cp_img(){
    s=$1
    e=$2
    for x in $(seq -f "%05g" $s $e)
    do
        cp img_db/${x}.jpeg images/
    done
}


# 各卷 html 起始位置
htmls=(1 20 448 643 853 1063 1410 1686 2037 2452 2744 3018 3411 3435 3448 3502 3518 3580 3588 3601 4377 5127 5926 7112 8103 8805 9555 10368 11371 12100 12903 13578)
# 各卷图片起始位置
imgs=(1 13 44 59 102 124 162 318 351 437 513 547 561 581 757 1264 1328 1359 1374 1390 1440 1456 1490 1517 1544 1680 1718 1775 1819 1874 1909 1949)
# 各卷封面图片编号
covers=(00002 00013 00044 00059 00103 00125 00163 00319 00351 00438 00513 00548 00561 00582 00758 01264 01329 01359 01374 01390 01441 01457 01490 01518 01544 01680 01718 01775 01819 01875 01910)
# 副标题
subtitle=("奏稿之一" "奏稿之二" "奏稿之三" "奏稿之四" "奏稿之五" "奏稿之六" "奏稿之七" "奏稿之八" "奏稿之九" "奏稿之十" "奏稿之十一" "奏稿之十二" "披牍" "诗文" "读书录" "日记之一" "日记之二" "日记之三" "日记之四" "家书之一" "家书之二" "书信之一" "书信之二" "书信之三" "书信之四" "书信之五" "书信之六" "书信之七" "书信之八" "书信之九" "书信之十")
# 总卷数
vol_num=31

if [[ ! -d "output" ]]
then
    mkdir output
fi
cd .tmp/

# 需要修改的文件先另外存档
mv text html_db
mv images img_db
mv content.opf content
mv toc.ncx toc

for ((i=0; i<$vol_num; i++))
do
    # 卷名
    title=曾国藩全集卷$[$i+1]：${subtitle[$i]}
    echo ">>> $title"

    # 清除上一步的残余
    rm -rf text
    rm -rf images
    mkdir text
    mkdir images

    # 图片范围
    is=${imgs[$i]}
    ie=$[${imgs[$[$i+1]]}-1]
    # html 范围
    hs=${htmls[$i]}
    he=$[${htmls[$[$i+1]]}-1]

    # 拷贝出本卷的图片和 html
    cp_img $is $ie
    cp_html $hs $he

    # 修改 content.opf 文件
    awk -f ../content.awk content "${title}" $is $ie $hs $he > content.opf

    # 修改 toc.ncx 文件
    awk -f ../toc.awk toc "${title}" $[$i+1] > toc.ncx

    # 压缩
    zip -q -r ../output/"${title}.epub" images/ META-INF text content.opf mimetype page_styles.css page_styles1.css stylesheet.css toc.ncx
    echo ">>> OK!"
done

# 收尾工作
cd ..
rm -rf .tmp
endtime=$(date +%s)
echo "总共耗时 "$((endtime-starttime))"s"
