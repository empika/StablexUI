package ru.stablex.ui.widgets;

import nme.events.MouseEvent;
import ru.stablex.ui.misc.RadioGroup;


/**
* Basic "option box" control
*
*/
class Radio extends Checkbox{
    //all registered groups
    static public var groups : Hash<RadioGroup> = new Hash();


    //group name for this control
    public var group (default,_setGroup) : String;


    /**
    * Setter for `.group`
    *
    */
    private function _setGroup (g:String) : String {
        //remove from old group
        if( this.group != null && Radio.groups.exists(this.group) ){
            Radio.groups.get(this.group).remove(this);
            this.selected = false;
        }

        //add to new group
        if( g != null ){
            if( !Radio.groups.exists(g) ){
                Radio.groups.set(g, new RadioGroup());
            }

            var lst = Radio.groups.get(g);
            lst.add(this);
            this.group = g;

            //if this is selected, we should unselect other options in group
            if( this.selected ){
                this._unselectOthers();
            }
        }

        return g;
    }//function _setGroup()


    /**
    * Unselect other options in group
    *
    */
    private function _unselectOthers () : Void {
        if( this.group != null ){
            var lst = Radio.groups.get(this.group);

            if( lst != null ){

                for(option in lst){
                    if( option != this ){
                        option.selected = false;
                    }
                }
            }//if( lst != null )
        }//if( this.group != null )
    }//function _unselectOthers()


    /**
    * Set specified state. On select we should unselect other options in group
    *
    */
    override public function set (state:String) : Void {
        super.set(state);

        if( state == 'down' ){
            this._unselectOthers();
        }
    }//function set()


    /**
    * Set next state
    *
    */
    override public function nextState (e:MouseEvent = null) : Void {
        if( this.selected ) return;

        //order must be defined
        if( this.order == null || this.order.length == 0 ) return;

        super.nextState(e);

        if( this.state == 'down' ){
            this._unselectOthers();
        }
    }//function nextState()


    /**
    * On radio desrtoy, remove it from group
    *
    */
    override public function free (recursive:Bool = true) : Void {
        this.group = null;
        super.free(recursive);
    }//function free()
}//class Radio