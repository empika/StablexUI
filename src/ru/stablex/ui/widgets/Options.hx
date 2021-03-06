package ru.stablex.ui.widgets;

import nme.display.DisplayObject;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.Lib;
import ru.stablex.ui.events.WidgetEvent;
import ru.stablex.ui.skins.Skin;



/**
* Simple options box.
* E.g. drop-down. Or list can appear full screen on top of the stage - `phone`-style
* <type>ru.stablex.ui.widgets.Button</type> widget is used to render options in list.
*/
class Options extends Button{
    /**
    * Array of title=>value pairs. Like [['red', 0xFF0000], ['green', 0x00FF00], ['blue', 0x0000FF]]
    * First element in these pairs must be of <type>String</type> type.
    * First option is selected by default
    */
    public var options (default,_setOptions) : Array<Array<Dynamic>>;
    //List wich appears when control is clicked
    public var list : Floating;
    //box is a child for `.list` and contains buttons for each option
    public var box : Box;
    //Currently selected value. If you try to set value wich is not in the `.options`, than `.value` won't be changed
    public var value (_getValue,_setValue) : Dynamic;
    //skin to use for options in list
    public var skinOption : Skin;
    //set skin for options by skin name
    public var skinOptionName (default,_setSkinOptionName) : String;
    //skin to use for selected option in list
    public var skinSelected : Skin;
    //set skin for selected option by skin name
    public var skinSelectedName (default,_setSkinSelectedName) : String;
    //defaults for options in list
    public var defaultsOption : String = 'Default';
    //defaults for selected option in list
    public var defaultsSelected : String = 'Default';
    //If this is true. List position will be overriden to make list appear under this control
    public var alignList : Bool = true;

    //if `.options` changed, we need to rebuild list of options
    private var _rebuildList : Bool = true;
    //currently selected option index in `.options`
    private var _selectedIdx (default,_setSelectedIdx) : Int = 0;


    /**
    * Constructor
    *
    */
    public function new () : Void {
        super();

        this.list = UIBuilder.create(Floating);
        this.box = UIBuilder.create(Box);
        this.list.addChild(this.box);

        this.box.unifyChildren = true;

        this.addEventListener(MouseEvent.CLICK, this.toggleList);
        this.list.addEventListener(MouseEvent.CLICK, this.toggleList);
    }//function new()


    /**
    * Setter for `._selectedIdx`
    * @dispatch <type>ru.stablex.ui.events.WidgetEvent</type>.CHANGE
    */
    private function _setSelectedIdx (idx:Int) : Int {
        if( idx != this._selectedIdx ){
            this._rebuildList = true;
            this._selectedIdx = idx;
            this.dispatchEvent(new WidgetEvent(WidgetEvent.CHANGE));
        }
        return idx;
    }//function _setSelectedIdx()


    /**
    * Setter for `.options`
    *
    */
    private function _setOptions (o:Array<Array<Dynamic>>) : Array<Array<Dynamic>> {
        if( o == null || o.length == 0 ){
            Err.trigger('Option list must not be null or empty');
        }

        //check options are correct
        for(i in 0...o.length){
            if( o[i].length != 2 || !Std.is(o[i][0], String) ){
                Err.trigger('Wrong options list format. Should be [[String,Dynamic], [String,Dynamic], ...] instead of ' + Std.string(o));
            }
        }

        this._selectedIdx = 0;
        this.text         = o[ this._selectedIdx ][0];

        return this.options = o;
    }//function _setOptions()


    /**
    * Setter for `.skinOptionName`
    *
    */
    private function _setSkinOptionName (s:String) : String {
        this.skinOption = UIBuilder.skin(s)();
        return this.skinOptionName = s;
    }//function _setSkinOptionName()


    /**
    * Setter for `.skinSelectedName`
    *
    */
    private function _setSkinSelectedName (s:String) : String {
        this.skinSelected = UIBuilder.skin(s)();
        return this.skinSelectedName = s;
    }//function _setSkinSelectedName()


    /**
    * Getter for `.value`
    *
    */
    private function _getValue () : Dynamic {
        if(
            this.options == null
            || this.options.length <= this._selectedIdx
        ){
            return null;
        }else{
            return this.options[ this._selectedIdx ][1];
        }
    }//function _getValue()


    /**
    * Setter for `.value`
    *
    */
    private function _setValue (v:Dynamic) : Dynamic {
        if( this.options != null ){
            for(i in 0...this.options.length){
                if( this.options[i][1] == v ){
                    this._selectedIdx = i;
                    break;
                }
            }
        }

        return v;
    }//function _setValue()


    /**
    * Show options list
    *
    */
    public function toggleList (e:MouseEvent = null) : Void {
        //if list is shown, hide it
        if( this.list.shown ){
            this.list.hide();

        //show list
        }else{

            if( this._rebuildList ){
                this._buildList();
                this._rebuildList = false;
            }

            var renderTo : DisplayObject = (
                this.list.renderTo == null
                    ? Lib.current
                    : UIBuilder.get(this.list.renderTo)
            );
            if( renderTo == null && this.parent != null ){
                renderTo = this.parent;
            }

            if( renderTo != null ){
                if( this.alignList ){
                    var rect : Rectangle = this.getRect(renderTo);
                    this.list.left = rect.x + (this.w - this.list.w) / 2;
                    this.list.top  = rect.y + this.h;
                }
                this.list.show();
            }
        }
    }//function toggleList()


    /**
    * Build list based on `.options`
    *
    */
    private function _buildList () : Void {
        if( this.options == null ) return;

        this.box.freeChildren();

        for(i in 0...this.options.length){
            this.box.addChild(UIBuilder.create(Button, {
                skin     : (this._selectedIdx == i ? this.skinSelected : this.skinOption),
                defaults : (this._selectedIdx == i ? this.defaultsSelected : this.defaultsOption),
                name     : Std.string(i),
                text     : this.options[i][0],
            })).addEventListener(MouseEvent.CLICK, this._onSelectOption);
        }

        this.box.refresh();
        this.list.refresh();
    }//function _buildList()


    /**
    * Process option selection
    *
    */
    private function _onSelectOption (e:MouseEvent) : Void {
        var obj : Button = cast e.currentTarget;

        if( obj != null ){
            var idx : Int = Std.parseInt(obj.name);
            if( this.options != null && this.options.length > idx ){
                this._selectedIdx = idx;
                this.text = this.options[idx][0];
            }
        }
    }//function _onSelectOption()


    /**
    * Destroy widget and list
    *
    */
    override public function free (recursive:Bool = true) : Void {
        this.list.free();
        super.free(recursive);
    }//function free()
}//class Options