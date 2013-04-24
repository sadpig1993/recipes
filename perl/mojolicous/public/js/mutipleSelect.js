
//todo

function MoveSelectedItem(sel_source, sel_dest)
{
    if (sel_source.selectedIndex==-1) return;

    for(var j=0; j<sel_source.length; j++)
    {
        if(sel_source.options[j].selected)
        {
            var SelectedText = sel_source.options[j].text;
            var SelectedCode = sel_source.options[j].value
            sel_dest.options.add(new Option(SelectedText,SelectedCode));
            sel_dest.options[sel_dest.length-1].selected = true;
            sel_source.options.remove(j);
            j--;
        }
    }
}

function MoveAllItems(sel_source, sel_dest)
{
    var sel_source_len = sel_source.length;
    for (var j=0; j<sel_source_len; j++)
    {
        var SelectedText = sel_source.options[j].text;
        var SelectedCode = sel_source.options[j].value
        sel_dest.options.add(new Option(SelectedText,SelectedCode));
        sel_dest.options[sel_dest.length-1].selected = true;
    }

    while ((k=sel_source.length-1)>=0)
    {
        sel_source.options.remove(k);
    }
}

function SelectAll(theSel)
{
  if(null != theSel){
      for (i = 0 ;i<theSel.length;i++)
            theSel.options[i].selected = true;
  }
}

function SelectAll(theSel1, theSel2){
  if(null != theSel1){
      for (i = 0 ;i<theSel1.length;i++)
            theSel1.options[i].selected = true;
  }
  if(null != theSel2){
      for (i = 0 ;i<theSel2.length;i++)
            theSel2.options[i].selected = true;
  }
}

function SelectAll(theSel1, theSel2, theSel3){
  if(null != theSel1){
      for (i = 0 ;i<theSel1.length;i++)
            theSel1.options[i].selected = true;
  }
  if(null != theSel2){
      for (i = 0 ;i<theSel2.length;i++)
            theSel2.options[i].selected = true;
  }
  if(null != theSel3){
      for (i = 0 ;i<theSel3.length;i++)
            theSel3.options[i].selected = true;
  }
}


function SelectAll(theSel1, theSel2, theSel3, theSel4){
  if(null != theSel1){
      for (i = 0 ;i<theSel1.length;i++)
            theSel1.options[i].selected = true;
  }
  if(null != theSel2){
      for (i = 0 ;i<theSel2.length;i++)
            theSel2.options[i].selected = true;
  }
  if(null != theSel3){
      for (i = 0 ;i<theSel3.length;i++)
            theSel3.options[i].selected = true;
  }
  if(null != theSel4){
      for (i = 0 ;i<theSel4.length;i++)
            theSel4.options[i].selected = true;
  }
}
