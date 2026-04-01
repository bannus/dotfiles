$file = "bvt-analysis.playlist"
$allMAMBVTs = Get-Content E:\developer\bavander\Scripts\MAM-BVT.txt
$BVTsToRun = Get-Content tests.txt

'<Playlist Version="1.0">' >> $file
foreach($BVT in $BVTsToRun) {
    $fullBVT = $allMAMBVTs -like "*.$BVT"
    "<Add Test=`"$fullBVT`" />" >> $file
}
'</Playlist>' >> $file
