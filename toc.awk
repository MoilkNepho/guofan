BEGIN {
    if (ARGC < 4) {
        print("参数错误，退出..");
		exit;
	}

    book_name = ARGV[2];
    vol = ARGV[3];
    ARGC = 2;

    point_count = 0;
    start = 0;
}

$1 ~ /<text>曾国藩全集<\/text>/ {
    printf("    <text>%s</text>\n", book_name);
    next;
}

$1 ~ /<text/ {
    if (point_count >= 1) {
        print($0);
    } else if (match($1, /曾国藩全集[0-9]+/)) {
        mvol = substr($1, RSTART + 15, RLENGTH - 15);
        if (mvol - vol == 0) {
            # print("      <navPoint class=\"chapter\" id=\"num_1\" playOrder=\"1\">");
            # print("        <navLabel>");
            # print("          <text>封面</text>");
            # print("        </navLabel>");
            # print("        <content src=\"cover.xhtml\"/>");
            # print("      </navPoint>");
            point_count = 1;
        }
    }
    next;
}

$1 ~ /<navPoint/ {
    if (point_count >= 1) {
        print($0);
        point_count = point_count + 1;
        start = 1;
    }
    next;
}
    
$1 ~ /<navLabel/ || $1 ~ /<\/navLabel/ || $1 ~ /<content/{
    if (start == 1) {
        print($0);
    }
    next;
}

$1 ~ /<\/navPoint/ {
    if (point_count <= 0) next;

    point_count = point_count - 1;
    # 目录结束
    if (point_count == 0) {
        print("  </navMap>");
        print("</ncx>");
        print("");
        exit;
    }
    print($0);
    next;
}

{
    print($0);
}
