import 'package:flutter/material.dart' hide Image;
import 'link_info.dart';
import 'main.dart';
import 'prop.dart';
import 'dart:collection';
import 'dart:ui';
import 'dart:math';
import 'dart:typed_data';

const BLACK_NORMAL = Color(0xff000000);
const COLOR_NORMAL = Color(0xff00ff00);
const SUBCOLOR_NORMAL = Color(0xffff0000);
const PALECOLOR_NORMAL = Color(0xffffff77);

class Corp {
  //int						id;

  MyHomePageState? connectron;
  String home = "";
  late String kt;
  late String type;
  late double x, y, z;
  late double vx, vy, vz;
  late double px, py, pz;
  late String text;
  double depz = 0.0;
  double coulomb = 0.0;

  List<Image> images = [];
  List<String> imageNames = [];
  Map<Corp, LinkInfo> connections = {};
  Map<Corp, LinkInfo> backconnections = {};
  bool selected = false;
  bool hilighted = false;
  bool visible = true;

  static Uint8List buffer = new Uint8List(200000);
  double size = 32;
  static Set<Corp> selectedList = new HashSet<Corp>();
  //static Corp			drag;
  static String paleColor = "#ffffff77";
  //static JTextField	textfield = new JTextField();
  static Prop prop = Prop();
  static List<Corp> corpList = [];
  static Map<String, Corp> corpMap = {};
  static bool autosave = false;
  //static Map<String,Corp>		corpNameMap = new HashMap<String,Corp>();

  String selectedLink = "";

  Color color = COLOR_NORMAL;
  Color subcolor = SUBCOLOR_NORMAL;

  void setColor(int color) {
    colorFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(color)
      ..isAntiAlias = true;
  }

  var blackStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = BLACK_NORMAL
    ..isAntiAlias = true;

  var colorFill = Paint()
    ..style = PaintingStyle.fill
    ..color = COLOR_NORMAL
    ..isAntiAlias = true;

  var subColorFill = Paint()
    ..style = PaintingStyle.fill
    ..color = SUBCOLOR_NORMAL
    ..isAntiAlias = true;

  var paleColorFill = Paint()
    ..style = PaintingStyle.fill
    ..color = PALECOLOR_NORMAL
    ..isAntiAlias = true;

  void swapColors() {
    Color oldcolor = color;
    color = subcolor;
    subcolor = oldcolor;
  }

  void appendName(String newname) {
    List<String> namesplit = name.split("\n");
    if (name == null || name.length == 0)
      name = newname;
    else if (!namesplit.map((e) => e.split("/")[0]).contains(newname))
      name += '\n' + newname;
    else {
      namesplit = namesplit.map((e) {
        List<String> split = e.split("/");
        String first = split[0];
        if (first == newname) {
          if (split.length == 1) {
            return first + "/2";
          } else
            return first + "/" + (int.parse(split[1]) + 1).toString();
        } else {
          return e;
        }
      }).toList();
      name = namesplit.join("\n");
    }
  }

  void setCoulomb(double coulomb) {
    this.coulomb = coulomb;
  }

  double getCoulomb() {
    return this.coulomb;
  }

  double getSize() {
    return size;
  }

  void setSizeSingle(double size) {
    this.size = size;
  }

  Rect bounds = Rect.fromLTWH(0, 0, 0, 0);
  Rect getBounds() {
    return bounds;
  }

  void setBounds(double x, double y, double w, double h) {
    bounds = Rect.fromLTWH(x, y, w, h);
  }

  void setSize(int w, int h) {
    bounds = Rect.fromLTWH(bounds.left, bounds.top, w.toDouble(), h.toDouble());
  }

  bool hassaved = false;
  void saveRecursive() {
    this.save();
    hassaved = true;
    for (Corp c in this.getLinks()) {
      if (!c.hassaved) c.saveRecursive();
    }
  }

  static String newline = "\r\n";

  static int createIndex = 1;
  static String getCreateName() {
    String ret = "unknown" + createIndex.toString();
    createIndex += 1;
    return ret;
  }

  void save() {
    if (autosave) {
      bool succ = false;
    }

    for (String name in corpMap.keys) {
      Corp c = corpMap[name]!;
      if (c == this) {
        corpMap.remove(name);
        corpMap[c.getName()] = c;

        break;
      }
    }
  }

  double distance(Corp other) {
    double xval = x - other.x;
    double yval = y - other.y;
    double zval = z - other.z;
    return sqrt(xval * xval + yval * yval + zval * zval);
  }

  void deleteSave() {
    bool succ = false;
  }

  void delete() {
    deleteSave();

    MyHomePageState ct = this.getParent()!;

    ct.components.remove(this);
    this.setParent(null);

    //ct.remove( this );
    Corp? crp = corpMap.remove(this.getName().trim());
    for (Corp corp in corpList) {
      //corp = corpMap.get(name);
      if (corp.getLinks().contains(this)) {
        corp.connections.remove(this);
      }

      if (corp.getBackLinks().contains(this)) {
        corp.backconnections.remove(this);
      }
    }
    corpList.remove(this);
    //ct.repaint();
  }

  Corp() {
    int i = 0;
    String str = "unkown";
    String val = str + i.toString();
    while (corpMap.containsKey(val)) {
      i++;
      val = str + i.toString();
    }

    name = val;
    kt = "00";
    type = "unkown";
    x = 20;
    y = 20;
    z = 0;
    vx = 0;
    vy = 0;
    vz = 0;
    coulomb = 1000.0;

    init();
  }

  Corp.name(this.name) {
    kt = "00";
    type = "unkown";
    x = 20;
    y = 20;
    z = 0;
    vx = 0;
    vy = 0;
    vz = 0;
    coulomb = 1000.0;

    init();
  }

  Corp.sub(this.name, this.type, this.x, this.y) {
    kt = "00";
    z = 0;
    vx = 0;
    vy = 0;
    vz = 0;
    coulomb = 1000.0;

    this.setBounds(x, y, size, size);
    init();
  }

  Corp.subz(this.name, this.type, this.x, this.y, this.z) {
    kt = "00";
    vx = 0;
    vy = 0;
    vz = 0;
    coulomb = 1000.0;

    setBounds(x, y, size, size);
    init();
  }

  void properties() {
    Corp.prop.currentCorp = this;
    //Corp.prop.name.setText( getName().trim() );
    //Corp.prop.kt.setText( type );

    //Corp.prop.color = Corp.this.color;
    //Corp.prop.home.setText( Corp.this.home );

    //Corp.prop.text.setText( text );

    //Corp.this.getParent().add( Corp.prop );
    //Corp.this.getParent().setComponentZOrder( Corp.prop, 0 );
    //Corp.prop.setBounds( Corp.this.getX()+Corp.this.getWidth()+10, Corp.this.getY(), 400, 300 );
  }

  void setSelected(bool selected) {
    this.selected = selected;
    selectedList.add(this);
  }

  bool isSelected() {
    return this.selected;
  }

  void subselect(Corp c) {
    if (!c.selected) {
      c.selected = true;
      selectedList.add(c);
      for (Corp nc in c.getLinks()) {
        subselect(nc);
      }
    }
  }

  void deselectAll() {
    for (Corp c in selectedList) {
      c.selected = false;
    }
    selectedList.clear();
  }

  void init() {
    corpList.add(this);
    corpMap[this.getName().trim()] = this;

    //this.setToolTipText( name );

    /*MenuBar	popup = new MenuBar();
		popup.addItem( "Select subgraph", new Command() {
			void execute() {
				deselectAll();
				Corp.this.selected = false;
				subselect( Corp.this );
				Connectron ct = Corp.this.getParent();
				ct.requestFocus();
				ct.repaint();
			}
		});
		popup.addSeparator();
		popup.addItem( "Properties", new Command() {
			void execute() {
				properties();
			}
		});*/
  }

  Iterable<Corp> getLinks() {
    return connections.keys;
  }

  Iterable<Corp> getBackLinks() {
    return backconnections.keys;
  }

  void addLinkInner(Corp corp, String link, double strength, double offset) {
    LinkInfo? linkInfo = connections[corp];
    if (linkInfo == null) {
      linkInfo = new LinkInfo(strength, offset);
      connections[corp] = linkInfo;
      corp.backconnections[this] = linkInfo;
    }
    linkInfo.linkTitles.add(link);
  }

  void addLinkSub(Corp corp, Set<String> linknames) {
    LinkInfo? linkInfo = connections[corp];
    if (linkInfo == null) {
      linkInfo = new LinkInfo(0.001, 0.0);
      connections[corp] = linkInfo;
      corp.backconnections[this] = linkInfo;
    }
    linkInfo.linkTitles.addAll(linknames);
  }

  void addLinkSingle(Corp corp, String link) {
    addLinkInner(corp, link, 1.0, 0.0);
  }

  void addLink(Corp corp) {
    addLinkSingle(corp, "link");
  }

  bool hasLink(Corp corp) {
    return connections.containsKey(corp);
  }

  void removeLink(Corp c) {
    connections.remove(c);
    c.backconnections.remove(this);
  }

  //int xs;
  double getX() {
    return bounds.left;
  }

  //int ys;
  double getY() {
    return bounds.top;
  }

  double getWidth() {
    return bounds.width;
  }

  double getHeight() {
    return bounds.height;
  }

  void paintComponent(Canvas g) {
    if (visible) {
      if (images.length > 0) {
        Image img = images[0];
        if (img.width * this.getHeight() > this.getWidth() * img.height) {
          double h = (this.getWidth() * img.height) / img.width;
          g.drawImageRect(
              img,
              Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
              Rect.fromLTWH(
                  0.0, (this.getHeight() - h) / 2.0, this.getWidth(), h),
              Paint());
        } else {
          double w = (this.getHeight() * img.width) / img.height;
          g.drawImageRect(
              img,
              Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
              Rect.fromLTWH((this.getWidth() - w) / 2, 0, w, this.getHeight()),
              Paint());
        }
      } else {
        if (this.getWidth() > 0 && this.getHeight() > 0) {
          //g.arc
          //g.drawOval(this.getBounds(), blackStroke);
          g.drawOval(this.getBounds(), colorFill);
          //g.drawArc(this.getBounds(), 0, 2.0*pi, true, blackStroke);
          //g.drawArc(this.getBounds(), 0, 2.0*pi, true, colorFill);
          /*g.beginPath();
          g.setFillStyle( color );
          g.setStrokeStyle( "#000000" );
          g.arc( this.getWidth()/2, this.getHeight()/2, this.getWidth()/2, 0, 2.0*pi );
          g.closePath();
          g.fill();
          g.stroke();*/
        }
      }

      if (selected) {
        if (this.getWidth() > 0 && this.getHeight() > 0) {
          g.drawRect(getBounds(), paleColorFill);
          g.drawRect(getBounds(), blackStroke);
        }
      }
    }
  }

  late double pxs;
  late double pys;
  late double lxs;
  late double lys;
  void mousePressed(double x, double y, bool isShiftKeyDown, bool doubleClick) {
    //dragging = (me.getNativeButton() == NativeEvent.BUTTON_LEFT || isShiftKeyDown) && !doubleClick;
    /*if( me.getNativeButton() == NativeEvent.BUTTON_RIGHT ) {
			//Arrays.this.getParent().getComponents()

			//this.getParent().add( textfield );
			//textfield.setBounds( this.getX()-size, this.getY()+size, size*3, 25 );
			//textfield.setText( this.name );

			prop.currentCorp = this;
			prop.name.controller.text = this.getName().trim();
			prop.kt.controller.text = this.type;
			prop.color = this.color;
			//prop.home.setText( this.home );
			prop.text.controller.text = this.text;
			this.getParent().addProp( prop );
			//this.getParent().setComponentZOrder( prop, 0 );
			prop.setBounds( (this.getX()+this.getWidth()+10).toInt(), this.getY().toInt(), 400, 65 );
		}*/

    pxs = x;
    pys = y;
    lxs = this.getX();
    lys = this.getY();
    this.selected = true;
    //drag = this;
    //this.getParent().setComponentZOrder(this, 0);

    // hey new this.getParent().repaint();
  }

  /*void mouseReleased( MouseEvent e, int xx, int yy, bool isShiftKeyDown, bool doubleClick, Corp drag ) {
		/*if( drag != null ) {
			pxs += drag.getX();
			pys += drag.getY();
		}*/
		OpenPainter ct = this.getParent();
		Corp c = ct.getComponentAt( xx, yy );
		if( c != null && c != drag && drag != null ) {
			drag.addLink( c );
		} else if( !dragging && drag != null /*&& !(c instanceof Corp)*/ ) {
			Corp corp = Corp.sub( getCreateName(), "unknown", xx-size/2, yy-size/2 );
			corp.depz = drag.depz;
			ct.backtrack(xx-size/2, yy-size/2, drag.depz, ct.getWidth(), ct.getHeight(), corp);
			this.getParent().add( corp );
			drag.addLink( corp );
			drag = null;
		}

		dragging = false;

		try {
			if( drag != null ) {
				drag.saveRecursive();
				this.hasSaved();
			} else {
				this.saveRecursive();
				this.hasSaved();
			}
		} catch (e1) {
			e1.printStackTrace();
		}
		drag = null;

		int maxw = this.getParent().getWidth();
		int maxh = this.getParent().getHeight();
		for( Corp comp in this.getParent().getComponents() ) {
			if( comp.getX()+comp.getWidth()+10 > maxw ) maxw = (comp.getX()+comp.getWidth()+10).toInt();
			if( comp.getY()+comp.getHeight()+10 > maxh ) maxh = (comp.getY()+comp.getHeight()+10).toInt();
		}
		if( maxw > this.getParent().getWidth() || maxh > this.getParent().getHeight() ) {
			//this.getParent().setPixelSize( maxw, maxh );
		}

		this.pxs = -1;
		this.pys = -1;
		this.getParent().repaint();
	}

	void hasSaved() {
		bool hb = hassaved;
		hassaved = false;
		if( hb ) {
			for( Corp c in this.getLinks() ) {
				c.hasMoved();
			}
		}
	}*/

  void hasMoved() {
    bool hb = hasmoved;
    hasmoved = false;
    if (hb) {
      for (Corp c in this.getLinks()) {
        c.hasMoved();
      }
    }
  }

  bool hasmoved = false;
  void moveRelative(int x, int y, bool recursive) {
    hasmoved = true;

    double oldx = this.getx();
    double oldy = this.gety();
    double oldz = this.getz();

    MyHomePageState ct = this.getParent()!;
    ct.birta = false;
    ct.backtrack(this.getX() + x, this.getY() + y, this.depz, 0,
        /*ct.getWidth(), ct.getHeight()*/ 0, this);

    if (recursive) {
      for (Corp c in this.getLinks()) {
        if (!c.hasmoved)
          c.moveRelativeReal((this.getx() - oldx), (this.gety() - oldy),
              (this.getz() - oldz), recursive);
      }
    }

    ct.birta = true;
  }

  void moveRelativeVirt(double x, double y, bool recursive) {
    hasmoved = true;

    MyHomePageState? ct = this.getParent();
    ct!.birta = false;

    //Point	loc = this.getLocation();
    //this.setLocation(loc.x+x, loc.y+y);

    double oldx = this.getx();
    double oldy = this.gety();
    double oldz = this.getz();

    ct.backtrack(this.px + x, this.py + y, this.depz, 0,
        /*ct.getWidth(), ct.getHeight()*/ 0, this);
    /*this.setx( this.getx()+x );
		this.sety( this.gety()+y );
		this.setz( 0 );*/

    //this.x = loc.x+x; //this.getX();
    //this.y = loc.y+y; //this.getY();
    //System.err.println( this.x + "  " + this.y );

    if (recursive) {
      for (Corp c in this.getLinks()) {
        if (!c.hasmoved)
          c.moveRelativeReal((this.getx() - oldx), (this.gety() - oldy),
              (this.getz() - oldz), recursive);
      }
    }

    ct.birta = true;
  }

  void moveRelativeReal(double x, double y, double z, bool recursive) {
    hasmoved = true;

    MyHomePageState? ct = this.getParent();
    ct!.birta = false;

    //Point	loc = this.getLocation();
    //this.setLocation(loc.x+x, loc.y+y);

    //Spilling.backtrack( this.getX()-3+x, this.getY()-3+y, ct.getWidth(), ct.getHeight(), this );
    /*this.setx( this.getx()+x );
		this.sety( this.gety()+y );
		this.setz( 0 );*/

    //this.x = loc.x+x; //this.getX();
    //this.y = loc.y+y; //this.getY();
    //System.err.println( this.x + "  " + this.y );

    this.setx(this.getx() + x);
    this.sety(this.gety() + y);
    this.setz(this.getz() + z);

    if (recursive) {
      for (Corp c in this.getLinks()) {
        if (!c.hasmoved) c.moveRelativeReal(x, y, z, recursive);
      }
    }

    ct.birta = true;
  }

  bool dragging = false;
  /*void mouseDragged(MouseMoveEvent e, int npx, int npy, bool isshift ) {
		OpenPainter	ct = this.getParent();
		if( !isshift ) ct.fixed = true;

		prop.currentCorp = null;
		this.getParent().removeProp( prop );
		if( dragging ) {
			int dx = npx - pxs;
			int dy = npy - pys;

			//console( dx + "  " + dy );

			if( selectedList.length == 0 || !selectedList.contains(this) ) {
				moveRelative( dx, dy, true );
				hasMoved();
			} else {
				moveRelativeVirt( dx, dy, false );
				for( Corp c in selectedList ) {
					if( c != this ) {
						c.moveRelativeVirt( dx, dy, false );
					}
				}
				for( Corp c in selectedList ) {
					c.hasMoved();
				}
			}
		}
			//console( npx + "  " + npy );
		pxs = npx;
		pys = npy;

		this.getParent().repaint();
	}*/

  MyHomePageState? getParent() {
    return connectron;
  }

  void setParent(MyHomePageState? parent) {
    connectron = parent;

    /*if( connectron != null ) {
			Canvas canvas = connectron.getCanvas();
			canvas.addMouseDownHandler( this );
			canvas.addMouseUpHandler( this );
			canvas.addMouseMoveHandler( this );
			canvas.addKeyDownHandler( this );
			canvas.addKeyUpHandler( this );
		}*/
  }

  /* dart
  Char last = ' ';
	void keyPressed(KeyDownEvent e) {
		OpenPainter ct = this.getParent();
		int keycode = e.getNativeKeyCode();
		if( keycode == KeyCodes.KEY_ENTER ) {
			this.save();
			this.selected = false;
			//this.properties();
		} else if( keycode == KeyCodes.KEY_DELETE ) {
			this.delete();
		}
		ct.repaint();
	}

	void keyTyped(KeyPressEvent e) {
		Char keychar = e.getCharCode();
		int keycode = e.getNativeEvent().getKeyCode();
		String name = this.getName();
		if( keychar == '\b' ) {
			if( name.length > 0 ) this.setName( name.substring(0, name.length-1) );
		} else if( keycode != KeyCodes.KEY_ALT && keycode != KeyCodes.KEY_CTRL && keycode != KeyCodes.KEY_SHIFT ) {
			if( name.startsWith("unknown") ) {
				this.setName( ""+keychar );
			} else this.setName( name + keychar );
		}
	}*/

  late String name;
  String getName() {
    return name;
  }

  void setName(String name) {
    if (autosave) deleteSave();
    this.name = name;
    if (autosave) save();
  }

  double getx() {
    return x;
  }

  double gety() {
    return y;
  }

  double getz() {
    return z;
  }

  void setx(double x) {
    this.x = x;
  }

  void sety(double y) {
    this.y = y;
  }

  void setz(double z) {
    this.z = z;
  }
}
