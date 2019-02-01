#!/bin/bash
#
# The render plugin currently doesn't support applying a set of rendering settings to a 
# whole dataset. This script just itereates over a tab separated mapping file which
# maps a dataset name to a renderings settings file (can be json or yml).
# It retrieves the images ids of the datasets and calls the render plugin for each
# of the images. 
#
# Note: 
# - You need to log in first before running this script.
# - If any of the datasets has more than 100 images increase the --limit parameter!

#file="idr0050-all-renderingMapping.tsv"
#omero="/opt/omero/server/OMERO.server/bin/omero"
#render="/opt/omero/server/OMERO.server/bin/omero render set"
file="test.tsv"
omero="/Users/pwalczysko/Duesseldorf2018/OMERO.server-5.4.3-171-5739c9c-ice36-b893/bin/omero"
render="/Users/pwalczysko/Duesseldorf2018/OMERO.server-5.4.3-171-5739c9c-ice36-b893/bin/omero render set"
dataset="Dataset:"

while IFS='	' read -r f1 f2 f3
do
	if [[ "$f2" == "*" ]]
	then
		printf 'all \n'
		result=`$omero hql --ids-only --limit 1000 --style plain -q "select id from Dataset as d where d.name = '$f1'"`
		#if [[ !$datasetid_processed == Col* ]]
		#then
		IFS=',' read -r -a datasetid <<< $result
		for id in "${datasetid[@]}"
		do
			id=${id/* /}
			printf "$id \n"
			printf 'Applying rendering settings %s (dataset %s) to %s \n' "$f3" "$f1" "$id"
			$render "$dataset$id" "$f3"
			#fi
		done
	fi

	imageids=`$omero hql --ids-only --limit 1000 --style csv -q "select img from DatasetImageLink l join l.parent as ds join l.child as img where ds.name = '$f1'"`
	IFS=',' read -r -a array <<< $imageids
	
	for imageid in "${array[@]}"
	do
		imageid=${imageid/ */}
		if [[ $imageid == Image* ]]
		then
			printf 'Applying rendering settings %s (dataset %s) to %s \n' "$f3" "$f1" "$imageid"
			$render $imageid "$f3"
		fi
	done
done <"$file"

