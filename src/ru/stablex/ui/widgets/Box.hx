package ru.stablex.ui.widgets;

import nme.display.DisplayObject;
import ru.stablex.Err;


/**
* Children of this box are aligned relative to box bounds
*/
class Box extends Widget{

    //Should we arrange children vertically (true) or horizontally (false). True by default.
    public var vertical : Bool = true;
    //Setter for padding left, right, top, bottom.
    public var padding (never,_setPadding) : Float;
    //padding left
    public var paddingLeft   : Float = 0;
    //padding right
    public var paddingRight  : Float = 0;
    //padding top
    public var paddingTop    : Float = 0;
    //padding bottom
    public var paddingBottom : Float = 0;
    //Distance between children
    public var childPadding : Float = 0;
    /**
    * This should be like 'left,top' or 'bottom' or 'center,middle' etc.
    * Vertical: left, right, center. Horizontal: top, bottom, middle.
    * Use any other value to cancel alignment
    */
    public var align : String = 'center,middle';
    //set size depending on content size
    public var autoSize (never,_setAutoSize) : Bool;
    //set width depending on content width
    public var autoWidth                     : Bool = true;
    //set height depending on content height
    public var autoHeight                    : Bool = true;
    //if this is set to true, all children will be set to equal size to fit box size
    public var unifyChildren : Bool = false;


    /**
    * Setter for autoSize
    *
    */
    private function _setAutoSize (as:Bool) : Bool {
        return this.autoWidth = this.autoHeight = as;
    }//function _setAutoSize()


    /**
    * If width is set, disable autoWidth
    *
    */
    override private function _setWidth(w:Float) : Float {
        this.autoWidth = false;
        return super._setWidth(w);
    }//function _setWidth()


    /**
    * If width is set, disable autoWidth
    *
    */
    override private function _setWpt(wp:Float) : Float {
        this.autoWidth = false;
        return super._setWpt(wp);
    }//function _setWpt()


    /**
    * If height is set, disable autoHeight
    *
    */
    override private function _setHpt(hp:Float) : Float {
        this.autoHeight = false;
        return super._setHpt(hp);
    }//function _setHpt()


    /**
    * If height is set, disable autoHeight
    *
    */
    override function _setHeight(h:Float) : Float {
        this.autoHeight = false;
        return super._setHeight(h);
    }//function _setHeight()


    /**
    * Setter for padding
    *
    */
    private function _setPadding (p:Float) : Float {
        this.paddingTop = this.paddingBottom = this.paddingRight = this.paddingLeft = p;
        return p;
    }//function _setPadding()


    /**
    * Refresh widgets. Re-apply skin box and realigns children
    *
    */
    override public function refresh() : Void {
        if( this.autoWidth ) this._width = this._calcWidth();
        if( this.autoHeight ) this._height = this._calcHeight();

        super.refresh();
        this.alignElements();
    }//function refresh()


    /**
    * On resize refresh widget if `autoWidth` or `autoHeight` is set.
    * Otherwise just realign children
    *
    */
    override public function onResize() : Void {
        super.onResize();
        this.refresh();
    }//function onResize()


    /**
    * Set width based on content width
    *
    */
    private function _calcWidth () : Float {
        //if this is vertical box, set width = max child width
        if( this.vertical ){

            var w      : Float = 0;
            var child  : DisplayObject;
            var childW : Float = 0;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                child = this.getChildAt(i);
                if( child.visible ){
                    childW = Box._objWidth(child);
                    if( childW > w ){
                        w = childW;
                    }
                }
            }

            return w + this.paddingLeft + this.paddingRight;
        //if this is horizontal box set width = sum children width
        }else{
            var w : Float = this.paddingLeft + this.paddingRight;
            var child : DisplayObject;
            var visibleChildren : Int = 0;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( child.visible ){
                    w += Box._objWidth(child);
                    visibleChildren ++;
                }
            }

            return w + (visibleChildren - 1) * this.childPadding;
        }
    }//function _calcWidth()


    /**
    * Set width based on content width
    *
    */
    private function _calcHeight () : Float {
        //if this is vertical box, set height = sum child height
        if( this.vertical ){

            var h : Float = this.paddingTop + this.paddingBottom;
            var child : DisplayObject;
            var visibleChildren : Int = 0;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( child.visible ){
                    h += Box._objHeight(child);
                    visibleChildren ++;
                }
            }

            return h + (visibleChildren - 1) * this.childPadding;

        //if this is horizontal box set height = max child height
        }else{

            var h      : Float = 0;
            var childH : Float = 0;
            var child  : DisplayObject;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( child.visible ){
                    childH = Box._objHeight(child);
                    if( childH > h ){
                        h = childH;
                    }
                }
            }

            return h + this.paddingTop + this.paddingBottom;
        }
    }//function _calcHeight()


    /**
    * Align elements according to this.align
    *
    */
    public function alignElements () : Void {
        if( this.unifyChildren ){
            this._unifyChildren();
        }

        //если нет дочерних элементов
        if( this.numChildren == 0 ) return;

        var alignments : Array<String> = this.align.split(',');

        //выравниваем
        for(align in alignments){
            switch(align){
                case 'top'    : this._vAlignTop();
                case 'middle' : this._vAlignMiddle();
                case 'bottom' : this._vAlignBottom();
                case 'left'   : this._hAlignLeft();
                case 'center' : this._hAlignCenter();
                case 'right'  : this._hAlignRight();
            }
        }
    }//function alignElements()


    /**
    * Set all children equal size
    *
    */
    private function _unifyChildren () : Void {
        var visibleChildren : Int = 0;
        for(i in 0...this.numChildren){
            if( this.getChildAt(i).visible ){
                visibleChildren ++;
            }
        }

        var child : DisplayObject;

        //if this is vertical box
        if( this.vertical ){
            var childWidth  : Float = this._width - this.paddingLeft - this.paddingRight;
            var childHeight : Float = (this._height - this.paddingTop - this.paddingBottom - this.childPadding * (visibleChildren - 1)) / visibleChildren;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( Std.is(child, Widget) ){
                    cast(child, Widget).resize(childWidth, childHeight);
                }
            }

        //if this is horizontal box
        }else{
            var childWidth  : Float = (this._width - this.paddingLeft - this.paddingRight - this.childPadding * (visibleChildren - 1)) / visibleChildren;
            var childHeight : Float = this._height - this.paddingTop - this.paddingBottom;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( Std.is(child, Widget) ){
                    cast(child, Widget).resize(childWidth, childHeight);
                }
            }
        }
    }//function _unifyChildren()


    /**
    * Align top
    *
    */
    private function _vAlignTop () : Void {
        //vertical box
        if( this.vertical ){
            var lastY : Float = this.paddingTop;
            var child : DisplayObject;

            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                if( !child.visible ) continue;
                Box._setObjY(child, lastY);
                lastY += Box._objHeight(child) + this.childPadding;
            }

        //horizontal box
        }else{
            for(i in 0...this.numChildren){
                Box._setObjY(this.getChildAt(i), this.paddingTop);
            }
        }
    }//function _vAlignTop()


    /**
    * Align middle
    *
    */
    private function _vAlignMiddle () : Void {
        //vertical box
        if(this.vertical){
            //count sum children height
            var height          : Float = 0;
            var child           : DisplayObject;
            var visibleChildren : Int = 0;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( !child.visible ) continue;
                visibleChildren ++;
                height += Box._objHeight(child);
            }

            //add padding
            height += (visibleChildren - 1) * this.childPadding;

            //arrange elements
            var lastY : Float = (this.h - height) / 2;

            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                if( !child.visible ) continue;
                Box._setObjY(child, lastY);
                lastY   += Box._objHeight(child) + this.childPadding;
            }

        //horizontal box
        }else{
            var child : DisplayObject;
            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                Box._setObjY(child, (this.h - Box._objHeight(child)) / 2);
            }
        }
    }//function _vAlignMiddle()


    /**
    * Align bottom
    *
    */
    private function _vAlignBottom () : Void {
        //vertical box
        if( this.vertical ){
            var lastY : Float = this.h - this.paddingBottom;
            var child : DisplayObject;

            for(i in 0...this.numChildren){
                child   = this.getChildAt(this.numChildren - 1 - i);
                if( !child.visible ) continue;
                Box._setObjY(child, lastY - Box._objHeight(child));
                lastY   = child.y - this.childPadding #if html5 - (Std.is(child, nme.text.TextField) ? 2 : 0) #end;
            }

        //horizontal box
        }else{
            var child : DisplayObject;
            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                Box._setObjY(child, this.h - this.paddingBottom - Box._objHeight(child));
            }
        }
    }//function _vAlignBottom()


    /**
    * Align left
    *
    */
    private function _hAlignLeft () : Void {
        //vertical box
        if(this.vertical){
            for(i in 0...this.numChildren){
                Box._setObjX(this.getChildAt(i), this.paddingLeft);
            }

        //horizontal box
        }else{
            var lastX : Float = this.paddingLeft;
            var child : DisplayObject;

            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                if( !child.visible ) continue;
                Box._setObjX(child, lastX);
                lastX   += Box._objWidth(child) + this.childPadding;
            }
        }
    }//function _hAlignLeft()


    /**
    * Align right
    *
    */
    private function _hAlignRight () : Void {
        //vertical box
        if(this.vertical){
            var child : DisplayObject;
            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                Box._setObjX(child, this.w - this.paddingRight - Box._objWidth(child));
            }

        //horizontal box
        }else{
            var lastX : Float = this.w - this.paddingRight;
            var child : DisplayObject;

            for(i in 0...this.numChildren){
                child = this.getChildAt(this.numChildren - 1 - i);
                if( !child.visible ) continue;
                Box._setObjX(child, lastX - Box._objWidth(child));
                lastX = child.x #if html5 - (Std.is(child, nme.text.TextField) ? 2 : 0) #end - this.childPadding;
            }
        }
    }//function _hAlignRight()


    /**
    * Align center
    *
    */
    private function _hAlignCenter () : Void {
        //vertical box
        if(this.vertical){
            var child : DisplayObject;
            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                Box._setObjX(child, (this.w - Box._objWidth(child)) / 2);
            }

        //horizontal box
        }else{
            //sum children width
            var child           : DisplayObject;
            var width           : Float = 0;
            var visibleChildren : Int = 0;

            for(i in 0...this.numChildren){
                child = this.getChildAt(i);
                if( !child.visible ) continue;
                visibleChildren ++;
                width += Box._objWidth(child);
            }

            //add padding
            width += (visibleChildren - 1) * this.childPadding;

            //arrange elements
            var lastX : Float = (this.w - width) / 2;

            for(i in 0...this.numChildren){
                child   = this.getChildAt(i);
                if( !child.visible ) continue;
                Box._setObjX(child, lastX);
                lastX += Box._objWidth(child) + this.childPadding;
            }
        }
    }//function _hAlignCenter()



    /**
    * Strange bug: on html5 TextField.width (.height) reported is less than TextField.textWidth (.textHeight).
    * While on other targets .width (.height) is bigger by approximately 4 pixels.
    * That's why we need these functions.
    * {
    */

        /**
        * get object width
        *
        */
        static private inline function _objWidth (obj:DisplayObject) : Float {
            #if html5
                if( Std.is(obj, Widget) ){
                    return cast(obj, Widget).w;
                }else if( Std.is(obj, nme.text.TextField) ){
                    return cast(obj, nme.text.TextField).textWidth + 4;
                }else{
                    return obj.width;
                }
            #else
                return (Std.is(obj, Widget) ? cast(obj, Widget).w : obj.width);
            #end
        }//function _objWidth()


        /**
        * get object height
        *
        */
        static private inline function _objHeight (obj:DisplayObject) : Float {
            #if html5
                if( Std.is(obj, Widget) ){
                    return cast(obj, Widget).h;
                }else if( Std.is(obj, nme.text.TextField) ){
                    return cast(obj, nme.text.TextField).textHeight + 4;
                }else{
                    return obj.height;
                }
            #else
                return (Std.is(obj, Widget) ? cast(obj, Widget).h : obj.height);
            #end
        }//function _objHeight()


        /**
        * Set object x
        *
        */
        static private inline function _setObjX (obj:DisplayObject, x:Float) : Void {
            #if html5
                obj.x = (Std.is(obj, nme.text.TextField) ? obj.x = x + 2 : x);
            #else
                obj.x = x;
            #end
        }//function _setObjX()


        /**
        * Set object y
        *
        */
        static private inline function _setObjY (obj:DisplayObject, y:Float) : Void {
            #if html5
                obj.y = (Std.is(obj, nme.text.TextField) ? obj.y = y + 2 : y);
            #else
                obj.y = y;
            #end
        }//function _setObjY()

    /**
    * }
    */
}//class Box