import 'package:flutter/material.dart';
import 'link_info.dart';
import 'corp.dart';
import 'prop.dart';
import 'main.dart';
import 'dart:collection';
import 'dart:math' hide log;

const WHITE_NORMAL = Color(0xffffffff);
const BLACK_NORMAL = Color(0xff000000);
const BLUE_NORMAL = Color(0xff54c5f8);
const GREEN_NORMAL = Color(0xff6bde54);
const BLUE_DARK2 = Color(0xff01579b);
const BLUE_DARK1 = Color(0xff29b6f6);
const SEVEN_COLOR = Color(0xff777777);

class OpenPainter extends CustomPainter {
  List<Corp> corpList = [];

  bool drawLinks = true;
  bool drawLinkNames = true;
  bool drawNodeNames = true;

  bool isshift = false;
  bool dragging = false;

  MyHomePageState mhState;

  OpenPainter(this.mhState);

  /*int getWidth() {
    return 512;
  }

  int getHeight() {
    return 512;
  }*/

  var clearFill = Paint()
    ..style = PaintingStyle.fill
    ..color = BLUE_NORMAL
    ..isAntiAlias = true;

  var paintFill = Paint()
    ..style = PaintingStyle.fill
    ..color = BLUE_NORMAL
    ..isAntiAlias = true;

  var paintStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = BLUE_NORMAL
    ..isAntiAlias = true;

  var blackStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = BLACK_NORMAL
    ..isAntiAlias = true;

  var sevenStroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = SEVEN_COLOR
    ..isAntiAlias = true;

  double mincoulombradius = 0.10;
  void spring() {
    const double damp = 0.97;
    //final double u = 1000.0;
    const double gorm = 0.0;
    const double k = 1.0;

    num mcr = pow(mincoulombradius, 1.0 / 3.0);
    for (Corp corp in Corp.corpList) {
      double fx = 0;
      double fy = 0;
      double fz = 0;
      for (Corp c in Corp.corpList) {
        double dx = corp.getx() - c.getx();
        double dy = corp.gety() - c.gety();
        double dz = corp.getz() - c.getz();
        double d = dx * dx + dy * dy + dz * dz;
        double r = sqrt(d);
        double r2 = r * r;
        double r3 = r2 * r;

        double u = c.getCoulomb();
        if (r3 > mincoulombradius) {
          fx += (u * dx) / r3;
          fy += (u * dy) / r3;
          fz += (u * dz) / r3;
        } else {
          //fx += (u*dx*mcr)/(r*mincoulombradius);
          //fy += (u*dy*mcr)/(r*mincoulombradius);
          //fz += (u*dz*mcr)/(r*mincoulombradius);
        }
      }
      for (Corp c in corp.backconnections.keys) {
        double dx = corp.getx() - c.getx();
        double dy = corp.gety() - c.gety();
        double dz = corp.getz() - c.getz();

        double d = dx * dx + dy * dy + dz * dz;
        double r = sqrt(d);

        LinkInfo? li = corp.backconnections[c];
        double h = li!.getOffset();
        double st = li!.getStrength();
        //double k = li.getStrength();

        r = max(r, 0.1);
        //if( r > 0.1 ) {
        double dh = r - h;

        fx -= k * st * (dx * dh / r - gorm);
        fy -= k * st * (dy * dh / r - gorm);
        fz -= k * st * (dz * dh / r - gorm);
        //}
      }
      for (Corp c in corp.connections.keys) {
        double dx = corp.getx() - c.getx();
        double dy = corp.gety() - c.gety();
        double dz = corp.getz() - c.getz();

        double d = dx * dx + dy * dy + dz * dz;
        double r = sqrt(d);

        LinkInfo li = corp.connections[c]!;
        double h = li.getOffset();
        double st = li.getStrength();
        //double k = li.getStrength();

        r = max(r, 0.1);
        //if( r > 0.1 ) {
        double dh = r - h;

        fx = -k * st * (dx * dh / r - gorm);
        fy = -k * st * (dy * dh / r - gorm);
        fz = -k * st * (dz * dh / r - gorm);
        //}
      }

      for (Corp c in corp.connections.keys) {
        double dx = corp.getx() - c.getx();
        double dy = corp.gety() - c.gety();
        double dz = corp.getz() - c.getz();

        double d = dx * dx + dy * dy + dz * dz;
        double r = sqrt(d);

        LinkInfo li = corp.connections[c]!;
        double h = li.getOffset();
        double st = li.getStrength();
        //double k = li.getStrength();

        r = max(r, 0.1);
        //if( r > 0.1 ) {
        double dh = r - h;

        fx -= k * st * (dx * dh / r - gorm);
        fy -= k * st * (dy * dh / r - gorm);
        fz -= k * st * (dz * dh / r - gorm);
        //}
      }

      corp.vx = (corp.vx + fx) * damp;
      corp.vy = (corp.vy + fy) * damp;
      corp.vz = (corp.vz + fz) * damp;

      corp.setx(corp.getx() + corp.vx);
      corp.sety(corp.gety() + corp.vy);
      corp.setz(corp.getz() + corp.vz);

      //corp.setBounds( (int)(corp.x-Corp.size/2), (int)(corp.y-Corp.size/2), Corp.size, Corp.size );
    }
    //c.repaint();
  }

  @override
  void paint(Canvas g, Size size) {
    var sizewidth = size.width; //512.0;
    var sizeheight = size.height; //512.0;
    //size = Size(512,512);
    //debugPrint("logogo "+size.toString());
    //if( !painting ) {
    mhState.painting = true;
    if (!mhState.shift) {
      mhState.birta = false;
      if (mhState.toggle) {
        mhState.updateCenterOfMass();
        spring();
      }
      mhState.depth(sizewidth, sizeheight);
      mhState.birta = true;
    }

    //g.drawRect(Rect.fromLTWH(0, 0, sizewidth, sizeheight), clearFill);
    if (drawLinks) {
      //g.setStrokeStyle("#000000");

      for (Corp corp in mhState.getComponents()) {
        //Rectangle inrect = new Rectangle( this.getHorizontalScrollPosition(), this.getVerticalScrollPosition(), this.getWidth(), this.getHeight() ); //this.getVisibleRect();
        Rect inrect = Rect.fromLTWH(-sizewidth, -sizeheight, 2 * sizewidth,
            2 * sizeheight); //this.getVisibleRect();
        for (Corp cc in corp.getLinks()) {
          double x1 = corp.getX() + corp.getWidth() / 2;
          double y1 = corp.getY() + corp.getHeight() / 2;
          double x2 = cc.getX() + cc.getWidth() / 2;
          double y2 = cc.getY() + cc.getHeight() / 2;

          if (cc.depz > 0.0 &&
              (inrect.contains(Offset(x1, y1)) ||
                  inrect.contains(Offset(x2, y2)))) {
            Path path = Path();
            path.moveTo(x1, y1);
            path.lineTo(x2, y2);
            path.close();
            g.drawPath(path, sevenStroke);

            if (drawLinkNames && !mhState.toggle && mhState.px == -1) {
              Set<String> strset = corp.connections[cc]!.linkTitles;
              double x = (x1 + x2) / 2;
              double y = (y1 + y2) / 2;
              double t = atan2(y2 - y1, x2 - x1);

              g.translate(x, y);
              g.rotate(t); //, x, y);
              int k = 0;
              //g.setFillStyle( "#000000" );
              for (String str in strset) {
                if (str != "link") {
                  TextSpan textSpan = TextSpan(
                      text: str,
                      style: TextStyle(color: Colors.black, fontSize: 30));
                  final textPainter = TextPainter(
                    text: textSpan,
                    textDirection: TextDirection.ltr,
                  );
                  //TextMetrics tm = g.measureText( str );
                  double strw = textPainter.width;
                  textPainter.paint(g, Offset(-strw / 2, -5.0 - k));
                  //g.fillText( str, -strw/2, -5-k );
                  k += 10;
                }
              }
              g.rotate(-t); //, x, y);
              g.translate(-x, -y);
            }
          }
        }
      }
    }

    //g.setFillStyle( "#000000" );
    for (var corp in mhState.getComponents()) {
      if (corp.visible) {
        String corpName = corp.getName();
        corpName = corpName.substring(0, min(200, corpName.length));
        TextSpan textSpan = TextSpan(
            text: corpName,
            style: TextStyle(color: Colors.black, fontSize: 10));
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        double strWidth = textPainter.width;
        //if( (corp.type.equals("person") && drawNodeNames) || (corp.type.equals("corp") && drawCorpNames) ) {
        if (drawNodeNames) {
          textPainter.paint(
              g,
              Offset(corp.getX() + (corp.getWidth() - strWidth) / 2,
                  corp.getY() + corp.getHeight() + 15));
        }
      }
    }

    Corp? c = mhState.drag;
    if (c != null && !c.dragging && c.px != -1) {
      //g.setStrokeStyle("#000000");
      Path path = Path();
      path.moveTo(c.getX() + c.getWidth() / 2, c.getY() + c.getHeight() / 2);
      //console( "erm " + c.px + "  " + c.py );
      path.lineTo(c.pxs.toDouble(), c.pys.toDouble());
      path.close();
      g.drawPath(path, blackStroke);
    }

    for (Corp corp in mhState.getComponents()) {
      //g.translate( corp.getX(), corp.getY() );
      corp.paintComponent(g);
      //g.translate( -corp.getX(), -corp.getY() );
    }

    if (mhState.selRect != null) {
      g.drawRect(mhState.selRect!, blackStroke);
    }
    mhState.painting = false;
    //}

    /*if (size.width > 1.0 && size.height > 1.0) {
      print(">1.9");
      SizeUtil.size = size;
    }
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..color = BLUE_NORMAL
      ..isAntiAlias = true;

    canvas.drawCircle(new Offset(size.width/2, size.height/2), size.width/2, paint);

    //Rect rect = new Offset(0.0, 0.0)&size;
    //    paint..shader = new LinearGradient(colors: [Colors.white, color]
    //    ,begin: Alignment.topRight, end: Alignment.bottomLeft).createShader(rect);

    canvas.drawArc(new Offset(0.0, 0.0)
    &new Size(size.width, size.width), -90.0*0.0174533, progress*0.0174533,
      false, paint..color = color);*/
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    //debugPrint("hello");
    return true;
  }

  @override
  bool shouldRebuildSemantics(CustomPainter oldDelegate) {
    //debugPrint("hello");
    return true;
  }

  void remove(Corp c) {
    c.delete();
    //c.setParent( null );
  }

  void swapAllColors() {
    for (Corp c in Corp.corpList) {
      c.swapColors();
    }
  }
}
