import 'package:flutter/material.dart';
import 'corp.dart';

class Prop {
  //Connectron		connectron;
  Text? nLabel;
  Text? ktLabel;
  //JLabel			hmLabel;
  Text? textLabel;
  TextField? name;
  TextField? kt;
  RaisedButton? colorbutton;
  //JTextField		home;
  TextField? text;
  Color color = Color(0xffffffff);

  //JColorChooser	colorchooser = new JColorChooser();

  Corp currentCorp = Corp();
  Color lightGray = Color(0xffdddddd);

  void setBounds(int x, int y, int w, int h) {
    //this.setPopupPosition(x, y);
    //this.setPixelSize(w, h);
  }

  Prop() {
    /*nLabel = Text("Name:");
		ktLabel = Text("Type:");
		textLabel = Text("Text:");
		name = TextField("");
		kt = TextField("");
		text = new TextArea();
		colorbutton = new Button("color");
		text.setReadOnly( false );*/

    /*VerticalPanel	vp = new VerticalPanel();
		vp.add(nLabel);
		vp.add(ktLabel);
		vp.add(textLabel);
		vp.add(name);
		vp.add(kt);
		vp.add(text);
		vp.add(colorbutton);*/

    /*this.setSize("400px", "300px");
		this.add( vp );
		
		KeyPressHandler kl = new KeyPressHandler() {			
			@Override
			public void onKeyPress(KeyPressEvent e) {
				if( e.getNativeEvent().getKeyCode() == KeyCodes.KEY_ENTER ) {
					Connectron ct = Prop.this.getConnectron();
					ct.remove( Prop.this );
					ct.repaint();
				}
			}
		};*/
  }

  /*Connectron getConnectron() {
		return connectron;
	}*/
}
