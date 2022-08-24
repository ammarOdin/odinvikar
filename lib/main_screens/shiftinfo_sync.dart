import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class ShiftInfoSyncScreen extends StatefulWidget {
  const ShiftInfoSyncScreen({Key? key}) : super(key: key);

  @override
  State<ShiftInfoSyncScreen> createState() => _ShiftInfoSyncScreenState();
}

class _ShiftInfoSyncScreenState extends State<ShiftInfoSyncScreen> {
  bool linkExist = false;
  final urlController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  String? validateField(String? input){
    if (input == null || input.isEmpty){
      return "Feltet må ikke være tomt";
    } else if (!input.contains(new RegExp(r'^[a-zA-Z0-9,. !?+-]+$'))){
      return "Teksten indeholder ugyldige karakterer";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vagtsynkronisering"),
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.white,),),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Container(
            padding: EdgeInsets.only(left: 15, top: 30),
            child: Text(linkExist? "Synkroniseret" : "Ikke synkroniseret",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: linkExist? Colors.green : Colors.red),),
          ),
          Container(
            padding: EdgeInsets.only(left: 15, top: 20),
            child: Text("For at se vagtinformationer (klasse, timer, fag, tidspunkter) inde under dine arbejdsdage, skal du synkronisere dit Aula kalender med Vikarly.\n\nFølg nedenstående guide for at udføre synkroniseringen.",
              style: TextStyle(fontSize: 14, color: Colors.grey),),
          ),
          Container(
            margin: EdgeInsets.only(left: 15, right: 15, top: 40, bottom: 40),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.8), borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.transparent, shadowColor: Colors.transparent),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ShiftInfoGuide()));
                },
                child: Center(child: Row(children: [Align(alignment: Alignment.centerLeft, child: Text("Guide", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),)), const Spacer(), const Align(alignment: Alignment.centerRight, child: Icon(Icons.link, color: Colors.blue,))]),)
            ),
          ),
          const Divider(thickness: 2,),
          Form(
            key: _key,
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(top: 40, left: 15, right: 40),
                    child: TextFormField(validator: validateField, controller: urlController, decoration: const InputDecoration(icon: Icon(Icons.dataset_linked), hintText: "Kalender-URL", hintMaxLines: 10,),)),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.only(left: 15, right: 15),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton.icon(onPressed: () {
                      if(_key.currentState!.validate()){
                        try {

                        } catch (e) {

                        }
                      }

                    }, icon: const Icon(Icons.sync_sharp, color: Colors.white), label: const Align(alignment: Alignment.centerLeft, child: Text("Synkronisér", style: TextStyle(color: Colors.white),)), style: ButtonStyle(shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: const BorderSide(color: Colors.blue)
                        )
                    )),),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShiftInfoGuide extends StatefulWidget {
  const ShiftInfoGuide({Key? key}) : super(key: key);

  @override
  State<ShiftInfoGuide> createState() => _ShiftInfoGuideState();
}

class _ShiftInfoGuideState extends State<ShiftInfoGuide> {
  int currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Guide til vagtsynkronisering"),
        leading: IconButton(onPressed: () {Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios, size: 18, color: Colors.white,),),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Stepper(
            physics: ClampingScrollPhysics(),
            currentStep: currentStep,
            onStepTapped: (index) {
              setState(() {
                currentStep = index;
              });
            },
            onStepContinue: () {
              if (currentStep != 6){
                setState(() {
                  currentStep++;
                });
              }
            },
            onStepCancel: () {
              if (currentStep != 0){
                setState(() {
                  currentStep--;
                });
              }
            },
            steps: [
              Step(
                  isActive: currentStep >=0,
                  title: Text("Log ind på Aula"),
                  content: Text("Log ind på din Aula app og naviger til kalender.")),
              Step(
                  isActive: currentStep >=1,
                  title: Text("Kalendermenu"),
                  content: Column(
                    children: [
                      Image.asset('assets/guide/1.jpg', fit: BoxFit.scaleDown,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Inde på Aula appen, trykker du på Kalendermenu, set i venstre øverste hjørne."),
                      ),
                    ],
                  )),
              Step(
                  isActive: currentStep >=2,
                  title: Text("Kalendersynkronisering"),
                  content: Column(
                    children: [
                      Image.asset('assets/guide/2.jpg', fit: BoxFit.scaleDown,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Inde i kalendermenuen, tryk på Kalendersynkronisering."),
                      ),
                    ],
                  )),
              Step(
                  isActive: currentStep >=3,
                  title: Text("Vælg institution"),
                  content: Column(
                    children: [
                      Image.asset('assets/guide/3.jpg', fit: BoxFit.scaleDown,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Vælg din institution, som du arbejder for."),
                      ),
                    ],
                  )),
              Step(
                  isActive: currentStep >=4,
                  title: Text("Vælg skema"),
                  content: Column(
                    children: [
                      Image.asset('assets/guide/4.jpg', fit: BoxFit.scaleDown,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Afkryds skema i bunden af siden, og tryk gem."),
                      ),
                    ],
                  ),),
              Step(
                  isActive: currentStep >=5,
                  title: Text("Kopier link"),
                  content: Column(
                    children: [
                      Image.asset('assets/guide/5.png', fit: BoxFit.scaleDown,),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text("Kopier linket som findes i bunden af siden. Du skal kopiere linket der hører ind under Ugekalender."),
                      ),
                    ],
                  ),),
              Step(
                  isActive: currentStep >=6,
                  title: Text("Sæt ind"),
                  content: Text("Naviger tilbage fra denne side, og sæt det kopierede link ind på vagtsynkroniseringssiden - tryk dernæst synkronisér.")
              ),
            ],
          )
        ],
      ),
    );
  }
}

