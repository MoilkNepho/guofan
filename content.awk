BEGIN	{
	if (ARGC < 7) {
		exit;
	}
	book_name=ARGV[2];
	is=ARGV[3];
	ie=ARGV[4];
	hs=ARGV[5];
	he=ARGV[6];
	ARGC=2;
	ref_s=0;
	ref_e=0;
}

$NF ~ /曾国藩全集/ {
	gsub(/曾国藩全集/, book_name);
}

$NF ~ /media-type="image\/jpeg"/ {
	img_no=substr($2, 14, 5);
	if (img_no - is >= 0 && img_no - ie <= 0) {
		print($0);
	}
	next;
}

$NF ~ /media-type="application\/xhtml\+xml"/ {
	html_no=substr($2, 16, 5);
	ds = html_no - hs;
	de = html_no - he;
	if (ds >= 0 && de <= 0) {
		print($0);
		if (ds == 0) {
			refs = substr($3, 7, length($3) - 7);
		} else if (de == 0) {
			refe = substr($3, 7, length($3) - 7);
			# print("    <item id=\"cover.xhtml\" href=\"cover.xhtml\" media-type=\"application/xhtml+xml\"/>");
		}
	}
	next;
}

$1 ~ /<itemref/ {
	if (ref_e == 0) {
		id=substr($NF, 10, length($NF) - 12);
		if (id - refs == 0) {
			# print("    <itemref idref=\"cover.xhtml\"/>");
			ref_s = 1;
		} else if (id - refe == 0) {
			ref_e = 1;
		}
		if (ref_s == 1) {
			print($0);
		}
	}
	next;
}

$1 ~ /<reference/ {
	if ($2 ~ /.*titlepage.*/) {
		printf("    <reference type=\"cover\" title=\"封面\" href=\"part%04g.xhtml\"/>\n", hs);
	}
	next;
}

{
	print($0);
}