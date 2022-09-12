import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class ShiftCard extends StatelessWidget {
  final String text;
  final String subtitle;
  final Function() onPressed;

  const ShiftCard(
      {required this.text,
        required this.subtitle,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: const EdgeInsets.only(top: 15, bottom: 15, right: 15),
        margin: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const Spacer(),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailableShiftCard extends StatelessWidget {
  final String text;
  final String day;
  final String time;
  final Icon icon;
  final Icon icon2;
  final Function() onPressed;

  const AvailableShiftCard(
      {required this.text,
        required this.day,
        required this.icon,
        required this.icon2,
        required this.time,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        margin: const EdgeInsets.only(bottom: 10, right: 5, left: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 15),
                    child: Text(day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 10),
                    child: Text(text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 15, top: 10),
                    child: Text(time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        )),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
                padding: EdgeInsets.only(left: 5),
                child: icon),
            Container(
                padding: EdgeInsets.only(left: 5, right: 10),
                child: icon2),
          ],
        ),
      ),
    );
  }
}

class ActiveShiftCard extends StatelessWidget {
  final String text;
  final String day;
  final String time;
  final Icon icon;
  final Icon icon2;
  final Function() onPressed;

  const ActiveShiftCard(
      {required this.text,
        required this.day,
        required this.icon,
        required this.icon2,
        required this.time,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Badge(
        toAnimate: false,
        shape: BadgeShape.square,
        badgeColor: Colors.green,
        borderRadius: BorderRadius.circular(8),
        badgeContent: Text('Nuværende vagt', style: TextStyle(color: Colors.white)),
        position: BadgePosition.topEnd(end: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 120,
          padding: const EdgeInsets.only(top: 5, bottom: 5),
          margin: const EdgeInsets.only(bottom: 10, right: 5, left: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.green,
              width: 2.5
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                  offset: const Offset(5, 5),
                  blurRadius: 15,
                  color: Colors.grey.withOpacity(.5)),
            ],
          ),
          child: Row(
            children: [
              Container(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: Text(day,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 10),
                      child: Text(text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          )),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 15, top: 10),
                      child: Text(time,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          )),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                  padding: EdgeInsets.only(left: 5),
                  child: icon),
              Container(
                  padding: EdgeInsets.only(left: 5, right: 10),
                  child: icon2),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminAvailableShiftCard extends StatelessWidget {
  final String text;
  final String time;
  final String subtitle;
  final Icon icon;
  final Function() onPressed;

  const AdminAvailableShiftCard(
      {required this.text,
        required this.subtitle,
        required this.icon,
        required this.time,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 110,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 10),
                  child: Text(time,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      )),
                ),
              ],
            ),
            const Spacer(),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
            Container(
                padding: EdgeInsets.only(left: 5, right: 10),
                child: icon),
          ],
        ),
      ),
    );
  }
}

class ShiftSystemCard extends StatelessWidget {
  final String text;
  final String day;
  final String time;
  final Icon icon;
  final Icon icon2;
  final Function() onPressed;

  const ShiftSystemCard(
      {required this.text,
        required this.day,
        required this.time,
        required this.icon,
        required this.icon2,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 120,
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        margin: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.only(left: 15, top: 15),
                  child: Text(day,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      )),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 10),
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      )),
                ),
                Container(
                  padding: EdgeInsets.only(left: 15, top: 10),
                  child: Text(time,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      )),
                ),
              ],
            ),
            const Spacer(),
            Container(
                padding: EdgeInsets.only(left: 5),
                child: icon),
            Container(
                padding: EdgeInsets.only(left: 5, right: 10),
                child: icon2),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String text;
  final String imageUrl;
  final String subtitle;
  final Function() onPressed;

  const InfoCard(
      {required this.text,
        required this.imageUrl,
        required this.subtitle,
        required this.onPressed,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 75,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                offset: const Offset(5, 5),
                blurRadius: 15,
                color: Colors.grey.withOpacity(.5)),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: SizedBox(width: 60, height: 40, child: Image.asset(imageUrl, height: 59, fit: BoxFit.cover))),
            const SizedBox(
              width: 15,
            ),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )),
            const Spacer(),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.normal,
                  fontSize: 12),
            ),
          ],
        ),
      ),
    );

  }
}