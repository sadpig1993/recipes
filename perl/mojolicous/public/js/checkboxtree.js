//复选树

// Arrays for nodes and icons
var nodes = new Array();
var openNodes = new Array();
var icons = new Array(6);
var _parent = "";

var rootidex;

// Loads all icons that are used in the tree
function preloadIcons() {
    icons[0] = new Image();
    icons[0].src = "../images/tree/plus.gif";
    icons[1] = new Image();
    icons[1].src = "../images/tree/plusbottom.gif";
    icons[2] = new Image();
    icons[2].src = "../images/tree/minus.gif";
    icons[3] = new Image();
    icons[3].src = "../images/tree/minusbottom.gif";
    icons[4] = new Image();
    icons[4].src = "../images/tree/folder.gif";
    icons[5] = new Image();
    icons[5].src = "../images/tree/folderopen.gif";
}

// Create the tree
//arrName数组包含:{nodeID|parentID|name|description|selected(true/false)}
function createLinkTree(arrName, startNode, openNode, chkboxName) {

    nodes = arrName;
    if (nodes.length > 0) {
        preloadIcons();

        if (startNode == null) {
            alert("未指定根节点!");
            return;
        }
        if (openNode == null) {
            openNode = startNode;
        }

        rootidex = getArrayId(startNode);

        var openindex = getArrayId(openNode);

        if (rootidex != -1) {
            if (openindex == -1) {
                openindex = rootidex;
            }
            setOpenNodes(openindex);

            var nodeValues = nodes[rootidex].split("|");
            add(nodeValues[0]);
         
            document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' value='" + nodeValues[0]+"#" +nodeValues[2]+ "' onclick='checkSelect1(this,\"" + nodeValues[0]+ "\")'><img src=\"../images/tree/base.gif\" align=\"absbottom\" alt=\"\" />" + nodeValues[2] + "<br />");
            
        } else {
            alert("warn2!");
        }
        var recursedNodes = new Array();

        addLinkNode(startNode, recursedNodes, chkboxName);
    }
}
// Adds a new node to the tree
function addLinkNode(parentNode, recursedNodes, chkboxName) {
    for (var i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        add(nodeValues[0]);
        if (nodeValues[1] == parentNode && rootidex != i) {
            var ls = lastSibling(nodeValues[0], nodeValues[1]);
            var hcn = hasChildNode(nodeValues[0]);
            var ino = isNodeOpen(nodeValues[0]);

            // Write out line & empty icons
            for (g = 0; g < recursedNodes.length; g++) {
                if (recursedNodes[g] == 1) {
                    document.write("<img src=\"../images/tree/line.gif\" align=\"absbottom\" alt=\"\" />");
                } else {
                    document.write("<img src=\"../images/tree/empty.gif\" align=\"absbottom\" alt=\"\" />");
                }
            }

            // put in array line & empty icons
            if (ls) {
                recursedNodes.push(0);
            } else {
                recursedNodes.push(1);
            }

            // Write out join icons
            if (hcn) {
                if (ls) {
                    document.write("<a href=\"javascript: oc('" + nodeValues[0] + "', 1);\"><img id=\"join" + nodeValues[0] + "\" src=\"../images/tree/");
                    if (ino) {
                        document.write("minus");
                    } else {
                        document.write("plus");
                    }
                    document.write("bottom.gif\" align=\"absbottom\" alt=\"Open/Close node\" /></a>");
                } else {
                    document.write("<a href=\"javascript: oc('" + nodeValues[0] + "', 0);\"><img id=\"join" + nodeValues[0] + "\" src=\"../images/tree/");
                    if (ino) {
                        document.write("minus");
                    } else {
                        document.write("plus");
                    }
                    document.write(".gif\" align=\"absbottom\" alt=\"Open/Close node\" /></a>");
                }
            } else {
                if (ls) {
                    document.write("<img src=\"../images/tree/joinbottom.gif\" align=\"absbottom\" alt=\"\" />");
                } else {
                    document.write("<img src=\"../images/tree/join.gif\" align=\"absbottom\" alt=\"\" />");
                }
            }

            // Start link
            //document.write("<a target='deptManageFrame' href="" + nodeValues[3] + "" onmouseover="window.status='" + nodeValues[2] + "';return true;" onmouseout="window.status=' ';return true;">");

            // Write out folder & page icons
            if (hcn) {
                 document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' value='" +  nodeValues[0]+"#" +nodeValues[2]+ "' onclick='checkSelect1(this,\"" + nodeValues[0] + "\")'><img id=\"icon" + nodeValues[0] + "\" src=\"../images/tree/folder");
                
                 if (ino) {
                    document.write("open");
                }
                document.write(".gif\" align=\"absbottom\" alt=\"Folder\" />");
            } else {
               document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' value='" +  nodeValues[0]+"#" +nodeValues[2]+ "' onclick='checkSelect1(this,\"" + nodeValues[0] + "\")'>");
              
            }


            // Write out node name
            document.write(nodeValues[2]);

            // End link
            //document.write("</a><br />");
            document.write("<br />");

            // If node has children write out divs and go deeper
            if (hcn) {
                document.write("<div id=\"div" + nodeValues[0] + "\"");
                if (!ino) {
                    document.write(" style=\"display: none;\"");
                }
                document.write(">");
                addLinkNode(nodeValues[0], recursedNodes, chkboxName);
                document.write("</div>");
            }
            // remove last line or empty icon
            recursedNodes.pop();
        }
        decrease(nodeValues[0]);
    }
}
// Create the tree
//arrName数组包含:{nodeID|parentID|name|description|selected(true/false)}
function createTree(arrName, startNode, openNode, chkboxName) {

    nodes = arrName;
    if (nodes.length > 0) {
        preloadIcons();

        if (startNode == null) {
            alert("未指定根节点!");
            return;
        }
        if (openNode == null) {
            openNode = startNode;
        }

        rootidex = getArrayId(startNode);

        var openindex = getArrayId(openNode);

        if (rootidex != -1) {
            if (openindex == -1) {
                openindex = rootidex;
            }
            setOpenNodes(openindex);

            var nodeValues = nodes[rootidex].split("|");
            add(nodeValues[0]);
            document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' " + checked_value(nodeValues[4]) + " value='" + nodeValues[0] + "' onclick='checkSelect(this,\"" + nodeValues[0] + "\")'><img src=\"../images/tree/base.gif\" align=\"absbottom\" alt=\"\" />" + nodeValues[2] + "<br />");
        } else {
            alert("warn2!");
        }
        var recursedNodes = new Array();

        addNode(startNode, recursedNodes, chkboxName);
    }
}
// Returns the position of a node in the array
function getArrayId(node) {
    for (i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        if (nodeValues[0] == node) {
            return i;
        }
    }
    return -1;
}
//设置展开的节点,todo 参数应该也是一个数组,支持展开多个分支
function setOpenNodes(openNode) {
    for (i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        if (nodeValues[0] == openNode) {
            openNodes.push(nodeValues[0]);
            setOpenNodes(nodeValues[1]);
        }
    }
}
// Checks if a node is open
function isNodeOpen(node) {
    for (i = 0; i < openNodes.length; i++) {
        if (openNodes[i] == node) {
            return true;
        }
    }
    return false;
}
// Checks if a node has any children
function hasChildNode(parentNode) {
    for (i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        if (nodeValues[1] == parentNode) {
            return true;
        }
    }
    return false;
}
// Checks if a node is the last sibling
function lastSibling(node, parentNode) {
    var lastChild = 0;
    for (i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        if (nodeValues[1] == parentNode) {
            lastChild = nodeValues[0];
        }
    }
    if (lastChild == node) {
        return true;
    }
    return false;
}
// Adds a new node to the tree
function addNode(parentNode, recursedNodes, chkboxName) {
    for (var i = 0; i < nodes.length; i++) {
        var nodeValues = nodes[i].split("|");
        add(nodeValues[0]);
        if (nodeValues[1] == parentNode && rootidex != i) {
            var ls = lastSibling(nodeValues[0], nodeValues[1]);
            var hcn = hasChildNode(nodeValues[0]);
            var ino = isNodeOpen(nodeValues[0]);

            // Write out line & empty icons
            for (g = 0; g < recursedNodes.length; g++) {
                if (recursedNodes[g] == 1) {
                    document.write("<img src=\"../images/tree/line.gif\" align=\"absbottom\" alt=\"\" />");
                } else {
                    document.write("<img src=\"../images/tree/empty.gif\" align=\"absbottom\" alt=\"\" />");
                }
            }

            // put in array line & empty icons
            if (ls) {
                recursedNodes.push(0);
            } else {
                recursedNodes.push(1);
            }

            // Write out join icons
            if (hcn) {
                if (ls) {
                    document.write("<a href=\"javascript: oc('" + nodeValues[0] + "', 1);\"><img id=\"join" + nodeValues[0] + "\" src=\"../images/tree/");
                    if (ino) {
                        document.write("minus");
                    } else {
                        document.write("plus");
                    }
                    document.write("bottom.gif\" align=\"absbottom\" alt=\"Open/Close node\" /></a>");
                } else {
                    document.write("<a href=\"javascript: oc('" + nodeValues[0] + "', 0);\"><img id=\"join" + nodeValues[0] + "\" src=\"../images/tree/");
                    if (ino) {
                        document.write("minus");
                    } else {
                        document.write("plus");
                    }
                    document.write(".gif\" align=\"absbottom\" alt=\"Open/Close node\" /></a>");
                }
            } else {
                if (ls) {
                    document.write("<img src=\"../images/tree/joinbottom.gif\" align=\"absbottom\" alt=\"\" />");
                } else {
                    document.write("<img src=\"../images/tree/join.gif\" align=\"absbottom\" alt=\"\" />");
                }
            }

            // Start link
            //document.write("<a target='deptManageFrame' href="" + nodeValues[3] + "" onmouseover="window.status='" + nodeValues[2] + "';return true;" onmouseout="window.status=' ';return true;">");

            // Write out folder & page icons
            if (hcn) {
                document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' value='" + nodeValues[0] + "' " + checked_value(nodeValues[4]) + " onclick='checkSelect(this,\"" + nodeValues[0] + "\")'><img id=\"icon" + nodeValues[0] + "\" src=\"../images/tree/folder");
                if (ino) {
                    document.write("open");
                }
                document.write(".gif\" align=\"absbottom\" alt=\"Folder\" />");
            } else {
                document.write("<input type='checkbox' id='" + _parent + "' name='" + chkboxName + "' value='" + nodeValues[0] + "' " + checked_value(nodeValues[4]) + " onclick='checkSelect(this,\"" + nodeValues[0] + "\")'>");
            }


            // Write out node name
            document.write(nodeValues[2]);

            // End link
            //document.write("</a><br />");
            document.write("<br />");

            // If node has children write out divs and go deeper
            if (hcn) {
                document.write("<div id=\"div" + nodeValues[0] + "\"");
                if (!ino) {
                    document.write(" style=\"display: none;\"");
                }
                document.write(">");
                addNode(nodeValues[0], recursedNodes, chkboxName);
                document.write("</div>");
            }
            // remove last line or empty icon
            recursedNodes.pop();
        }
        decrease(nodeValues[0]);
    }
}
// Opens or closes a node
function oc(node, bottom) {
    var theDiv = document.getElementById("div" + node);
    var theJoin = document.getElementById("join" + node);
    var theIcon = document.getElementById("icon" + node);
    if (theDiv.style.display == "none") {
        if (bottom == 1) {
            theJoin.src = icons[3].src;
        } else {
            theJoin.src = icons[2].src;
        }
        theIcon.src = icons[5].src;
        theDiv.style.display = "";
    } else {
        if (bottom == 1) {
            theJoin.src = icons[1].src;
        } else {
            theJoin.src = icons[0].src;
        }
        theIcon.src = icons[4].src;
        theDiv.style.display = "none";
    }
}
function add(nodeId) {
    _parent += "~" + nodeId;
}
function decrease(nodeId) {
    _parent = _parent.substring(0, _parent.lastIndexOf("~"));
}

function checkSelect(node, nodeId) {
   // var checkbox = window.document.forms[0].namedItem(node.name);
	var checkbox = document.getElementsByName(node.name);
	
    for (i = 0; i < checkbox.length; i++) {

        var id = checkbox[i].id;
        var tmpId = node.id;
        temp = id.split("~");
        //选中全部子节点
        for (j = 0; j < temp.length; j++) {
            if (nodeId == temp[j])
                checkbox[i].checked = node.checked;
        }
        //选中全部父节点
        temp1 = tmpId.split("~");

        if (temp.length < temp1.length) {
            aa = true;
            for (j = 0; j < temp.length; j++) {
                if (temp[j] != temp1[j]) {
                    aa = false;
                    break;
                }
            }

            if (aa) {
                checkbox[i].checked = aa
            }
            ;
        }
    }
    //如果所有的子都没有选中，那么父也要不选中
    if (node.checked) return;
    if (node.id == "~0") return;
    var parentNode = getParent(node);

    if (parentNode == null) return;
    checkParent(parentNode);


}
function checkParent(parentNode) {
    var parentId = parentNode.id;
    var parentTemp = parentId.split("~");
   // var checkbox = window.document.forms[0].namedItem(parentNode.name);
    var checkbox = document.getElementsByName(parentNode.name);
    var isAnyCheck = false;
    for (i = 0; i < checkbox.length; i++) {

        var id = checkbox[i].id;
        temp2 = id.split("~");
        if (temp2.length > parentTemp.length) {

            bb = true;
            //判断是否是子节点
            for (j = 0; j < parentTemp.length; j++) {
                if (temp2[j] != parentTemp[j]) {
                    bb = false;
                    break;
                }
            }
            //如果子节点选中

            if (bb && checkbox[i].checked) {
                isAnyCheck = true;
                break;
            }
        }

    }
    if (i = checkbox.length && !isAnyCheck) {
        parentNode.checked = false;
        if (parentNode.id == "~0") return;
        var parentNode = getParent(parentNode);
        if (parentNode == null) return;
        checkParent(parentNode);
    }
}
function getParent(node) {

    var id = node.id;

    temp1 = id.split("~");

    if (temp1.length == 1) return null;
    //寻找父节点

    var str = "";
    for (j = 1; j < temp1.length - 1; j++) {
        str = str + "~" + temp1[j];
    }
	if(str=="") return null;
   // var parentNode = window.document.forms[0].namedItem(str);
	  var parentNode  = document.getElementById(str);
    return parentNode;
}

// Check the checkedvalue
function checked_value(check_value) {
    if (check_value == "false") {
        return "";
    } else {
        return "checked";
    }
}

// Push and pop not implemented in IE
if (!Array.prototype.push) {
    function array_push() {
        for (var i = 0; i < arguments.length; i++) {
            this[this.length] = arguments[i];
        }
        return this.length;
    }

    Array.prototype.push = array_push;
}
if (!Array.prototype.pop) {
    function array_pop() {
        lastElement = this[this.length - 1];
        this.length = Math.max(this.length - 1, 0);
        return lastElement;
    }

    Array.prototype.pop = array_pop;
}



function checkSelect1(node, nodeId) {
   // var checkbox = window.document.forms[0].namedItem(node.name);
	var  checkbox   = document.getElementsByName(node.name);
    for (i = 0; i < checkbox.length; i++) {
        var id = checkbox[i].id;
         if (nodeId == id)
            checkbox[i].checked = node.checked;
    }
}
