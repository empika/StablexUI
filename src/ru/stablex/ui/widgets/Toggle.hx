package ru.stablex.ui.widgets;



/**
* Simple <type>StateButton</type> with two states expected: "up" and "down"
*
*/
class Toggle extends StateButton{
    //wether button is in down/selected state
    public var selected (_getSelected,_setSelected) : Bool = false;


    /**
    * Constructor. Set `.order` = ['up', 'down'] by default.
    *
    */
    public function new () : Void {
        super();
        this.order = ["up", "down"];
    }//function new()


    /**
    * Getter for `.selected`
    *
    */
    private function _getSelected () : Bool {
        return this.state == 'down';
    }//function _getSelected()


    /**
    * Setter for `.selected`
    *
    */
    private function _setSelected (s:Bool) : Bool {
        if( s ){
            this.down();
        }else{
            this.up();
        }

        return s;
    }//function _setSelected()


    /**
    * Set "up" state
    *
    */
    public function up () : Void {
        this.set('up');
    }//function up()


    /**
    * Set "down" state
    *
    */
    public function down () : Void {
        this.set('down');
    }//function down()


    /**
    * Alias for <type>StateButton</type>.nextState()
    *
    */
    public function toggle () : Void {
        this.nextState();
    }//function toggle()
}//class Toggle