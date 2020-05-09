import Foundation
import SpriteKit

public class GameScene: SKScene {
    
    private var abed : SKSpriteNode!
    private var jeff : SKSpriteNode!
    private var troy : SKSpriteNode!
    private var shirley : SKSpriteNode!
    private var annie : SKSpriteNode!
    private var pierce : SKSpriteNode!
    private var britta : SKSpriteNode!
    
    private var text : SKLabelNode!
    var scrollText : [String] = []
    
    private var ball : SKSpriteNode!
    private var pen : SKSpriteNode!
    private var blorgon : SKSpriteNode!
    private var laser : SKEmitterNode!
    
    var moveCam: CGFloat?
    var scrollPosition: CGPoint?
    var blorgonHP = 3
    
    public override func didMove(to view: SKView) {
        //initialize characters
        
        camera = childNode(withName: "camera") as? SKCameraNode
        
        abed = childNode(withName: "abed") as? SKSpriteNode
        jeff = childNode(withName: "jeff") as? SKSpriteNode
        troy = childNode(withName: "troy") as? SKSpriteNode
        shirley = childNode(withName: "shirley") as? SKSpriteNode
        annie = childNode(withName: "annie") as? SKSpriteNode
        pierce = childNode(withName: "pierce") as? SKSpriteNode
        britta = childNode(withName: "britta") as? SKSpriteNode
        ball = childNode(withName: "ball") as? SKSpriteNode
        pen = childNode(withName: "pen") as? SKSpriteNode
        blorgon = childNode(withName: "blorgon") as? SKSpriteNode
        laser = blorgon.childNode(withName: "laser") as? SKEmitterNode
        
        text = childNode(withName: "text") as? SKLabelNode
    }
    
    @objc public static override var supportsSecureCoding: Bool {
        get {
            return true
        }
    }
    
    func touchDown(atPoint pos: CGPoint) {
        guard scrollPosition == nil else { return }
        scrollPosition = pos
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        return
    }
    
    func touchUp(atPoint pos : CGPoint) {
        let dist = scrollPosition?.distance(to: pos) ?? 0
        scrollPosition = nil
        
        if dist < 10 {
            let touchedNodes = self.nodes(at: pos)
            
            guard text.text == "" else {
                //scroll text if scrollable
                if text.text == "..." {
                    pierce.position = CGPoint(x: 623, y: -172)
                    
                    pierce.run(.sequence([
                        .setTexture(SKTexture(imageNamed: "pierce3")),
                        .group([
                            .fadeIn(withDuration: 1.5),
                            .playSoundFileNamed("respawn.m4a", waitForCompletion: true)
                        ]),
                        .customAction(withDuration: 0, actionBlock: { _,_  in
                            let switcher = [self.jeff, self.annie, self.shirley, self.britta, self.troy, self.abed]
                            for node in switcher {
                                node!.run(.setTexture(SKTexture(imageNamed: node!.name!+"3")))
                            }
                        }),
                        .moveBy(x: -30, y: -100, duration: 0.5)]))
                }
                
                text.text = scrollText.popLast() ?? ""
                return
            }
            
            guard let blorgon = blorgon else {
                setEndText(for: touchedNodes.first?.name)
                return
            }
            
            guard blorgon.alpha == 0 else {
                if touchedNodes.first?.name == "blorgon" {
                    blorgonHP -= 1
                    blorgon.run(.sequence([
                        .colorize(with: .red, colorBlendFactor: 0.5, duration: 0),
                        .wait(forDuration: 0.1),
                        .colorize(with: .red, colorBlendFactor: 0.0, duration: 0),
                        .playSoundFileNamed("hit.m4a", waitForCompletion: true)
                    ]))
                    
                    if blorgonHP == 0 {
                        pen.isHidden = false
                        
                        //unducking
                        let ducking = [self.jeff, self.annie, self.shirley, self.britta, self.troy, self.abed]
                        for node in ducking {
                            node!.size = CGSize(width: 60, height: 90)
                            node!.run(.setTexture(SKTexture(imageNamed: String(node!.name!))))
                        }
                        
                        let spark = SKEmitterNode(fileNamed:"spark")!
                        blorgon.addChild(spark)
                        blorgon.run(.sequence([.fadeOut(withDuration: 1), .removeFromParent()]))
                        
                        text.text = "Shirley: You saved us, thank you! \nBut oh no, look! Pierce was shot and died. That is so sad..."
                    }
                }
                return
            }
            
            guard pen.isHidden else {
                if touchedNodes.first?.name == "pen"{
                    self.blorgon = nil
                    annie.run(.sequence([.moveTo(x: 920, duration: 1), .customAction(withDuration: 0, actionBlock: { _,_  in
                        let switcher = [self.jeff, self.annie, self.shirley, self.britta, self.troy, self.abed]
                        for node in switcher {
                            node!.size = CGSize(width: 60, height: 90)
                            node!.run(.setTexture(SKTexture(imageNamed: node!.name!+"0")))
                        }
                    })]))
                    
                    setVictoryText()
                }
                return
            }
            
            doStartAction(for: touchedNodes.first?.name)
        }
        
    }
    
    func doStartAction(for objName: String?) {
        switch objName {
        case "jeff":
            jeff.run(.sequence([.setTexture(SKTexture(imageNamed: "jeff1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "jeff"))]))
            text.text = "What's up? I am Jeff Winger. I was a lousy lawyer who faked his bachelor degree \nand now I have to waste 3 years to get my old life back..."
            scrollText = ["and as if that's not enough, now we have to find this stupid pen. \nNobody cares about stuff like that anyway, am I right?"]
        case "britta":
            britta.run(.sequence([.setTexture(SKTexture(imageNamed: "britta1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "britta"))]))
            text.text = "Hello, my name is Britta Perry, yes I know, very funny... \nbut do you know what is not? I am a psych major and one day I am gonna be a REAL psychologist."
            scrollText = ["As a psych major I am completely aware that Annie has a very unhealthy relationship with that pen. \nBut it's not okay to restrain us in this room forever! \nThis is an attack on our human rights!!"]
        case "shirley":
            shirley.run(.sequence([.setTexture(SKTexture(imageNamed: "shirley1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "shirley"))]))
            text.text = "Hello fellow human being. I'm Shirely Bennet and I have 3 kids. \nI'd just wish André would be here with me. \nThis man has left me with nothing but a foggy memory of- ..."
            scrollText = ["Oh, never mind... \nI just hope Pierce hands over the pen soon. God knows what he used to scratch his leg."]
        case "annie":
            annie.run(.sequence([.setTexture(SKTexture(imageNamed: "annie1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "annie"))]))
            text.text = "Hello, my name is Annie, Annie Adderall. I just finished studying with our study group \nwhen I noticed that one of my pens are missing. As being the one who usually does most of the work, \nI am used to people borrowing stuff. \nBut this keeps happening. Someone steals my pens."
            scrollText = ["Who does something like that? Don't they know that if you fail school you will also fail life? \nAnyway, could you maybe have a look around and see if you can find anything? \nIt's purple with a gel grip."]
        case "pierce":
            pierce.run(.sequence([.setTexture(SKTexture(imageNamed: "pierce1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "pierce"))]))
            text.text = "Hello, my name is Pierce Hawkthorne. Yes, that is the Hawkthorne as in Hawkthorne Wipes. \nIn fact, since my father died recently I am the new CEO of the multi-billion dollar company."
            scrollText = ["I mainly come here to lean something new. This group of misfits is a necessary evil. \nApart from Annie. She is my favorite. I would never take her pen!"]
        case "troy":
            troy.run(.sequence([.setTexture(SKTexture(imageNamed: "troy1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "troy"))]))
            text.text = "Hey, this is... Troy Barns. Oh man, I almost said Butts Carlton. \nI was the star quarterback of Riverside High. \nSadly, I had a knee injury and lost my football scholarship..."
            scrollText = ["I don't know who took the pen. I'm just glad that Abed is here as well.\n*does cool handshake*"]
        case "abed":
            abed.run(.sequence([.setTexture(SKTexture(imageNamed: "abed1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "abed"))]))
            text.text = "Hi, I'm Abed Nadir and I'm a filmmaker. \nCurrently, I'm thinking of a film about this guy, who is coding this game, \nwhile having only a very limited time. \nI also like this pixel-version of myself..."
            scrollText = ["I don't like being forced to stay with other people. It confuses me. \nI'm so glad my best friend Troy is here.\nThe pen? I don't know, but maybe check out the far right side..?"]
        case "dean":
            text.text = ["Good morning, Greendale Community College. \nThis is your Dean reminding you that among your school's prestigious alumni is \nMr. Luis Guzmán, celebrated actor and model Puerto Rican-American.", "In campus news, the debate over our library's PA system \ncontinues with some students suggesting its volume be lowered \nwhile others question its very purpose."].randomElement()
        case "ball":
            text.text = "Troy: Man, I love sports. Anyone wanna play some basketball? \nWhat? No basket? Oh, that's right..."
            ball.run(.applyImpulse(CGVector(dx: 0, dy: 250), duration: 0.125))
        case "exit":
            text.text = "Annie: We can only go, when we find out who had the pen."
        case "plant":
            text.text = "Britta: I love nature. But the government is ruining everything with causing global warming.\nLook it up."
        case "table":
            text.text = "Jeff: Oh, that table. So many good memories of us... studying."
        case "bookshelf":
            text.text = "Annie: Watch out guys! BLORGONS!! \nBlorgon: *eradicate, eradicate...*"
            scrollText = ["Quick, help us defeat the Blorgon! I bet you can find a way to damage it..."]
            
            childNode(withName: "bookshelf")?.removeFromParent()
            
            let appear = SKAction.group([.fadeIn(withDuration: 1), .moveBy(x: -100, y: 0, duration: 1)])
            blorgon.run(.sequence([
                appear,
                .customAction(withDuration: 0, actionBlock: { _,_  in
                    let ducking = [self.jeff, self.annie, self.shirley, self.britta, self.troy, self.abed]
                    for node in ducking {
                        node!.size = CGSize(width: 80, height: 60)
                        node!.run(.setTexture(SKTexture(imageNamed: node!.name!+"2")))
                    }
                    
                    self.laser.isHidden = false
                    self.laser.run(.repeatForever(.sequence([.wait(forDuration: 0.25), .playSoundFileNamed("laser.m4a", waitForCompletion: true)])))
                }),
                .wait(forDuration: 0.75),
                .customAction(withDuration: 0, actionBlock: { _,_  in
                    self.pierce.run(.sequence([.colorize(with: .red, colorBlendFactor: 0.5, duration: 0), .wait(forDuration: 0.25), .colorize(with: .red, colorBlendFactor: 0.0, duration: 0), .fadeOut(withDuration: 1.5) ]))
                })
            ]))
            break
        default:
            return
        }
        
    }
    
    func setVictoryText() {
        text.text = "Jeff: HEY Annie, look! There's your pen. The Blorgon must have stolen it..."
        scrollText = [
            "We are... a Community!",
            "Jeff: Well, looks like we all learned an important lesson today. \nThat however small or big the problems we are facing, \nif we sick together we are unstoppable...",
            "Troy: Pierce, I'm we're so glad you are back! We almost thought we would've lost you forever!",
            "Abed: Cool, cool, cool.",
            "Pierce: I just found out that when you die here, you can come back to life. \nHow awesome is that?",
            "Pierce: Hey friends. \nEveryone: PIERCE!",
            "...",
            "Britta: No Annie, we are sorry. We should've appreciated your pen more. \nThen maybe this wouldn't have happened and Pierce would still be with us.",
            "Annie: You guys. I'm so sorry I accused you of taking my pen. \nI just feel like nobody ever takes me serious because I'm so young...",
        ]
    }
    
    func setEndText(for objName: String?) {
        switch objName {
        case "jeff":
            jeff.run(.sequence([.setTexture(SKTexture(imageNamed: "jeff1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "jeff"))]))
            text.text = "Wow. Now that's what I call a successful study."
        case "britta":
            britta.run(.sequence([.setTexture(SKTexture(imageNamed: "britta1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "britta"))]))
            text.text = "I like my plants, and my cats, and my friends..."
        case "shirley":
            shirley.run(.sequence([.setTexture(SKTexture(imageNamed: "shirley1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "shirley"))]))
            text.text = "My goodness, so much action. I'm getting to old for this..."
        case "annie":
            annie.run(.sequence([.setTexture(SKTexture(imageNamed: "annie1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "annie"))]))
            text.text = "I'm so glad Pierce is well. Would be crazy if he actually died because of a pen, right?"
        case "pierce":
            pierce.run(.sequence([.setTexture(SKTexture(imageNamed: "pierce4")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "pierce3"))]))
            text.text = "I don't even know what happened."
        case "troy":
            troy.run(.sequence([.setTexture(SKTexture(imageNamed: "troy1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "troy"))]))
            text.text = "*does cool handshake*"
        case "abed":
            abed.run(.sequence([.setTexture(SKTexture(imageNamed: "abed1")), .wait(forDuration: 2), .setTexture(SKTexture(imageNamed: "abed"))]))
            text.text = "What a cool game, isn't it? \nYea, cool. Cool, cool, cool."
        case "dean":
            text.text = ["Announcement number two, butt soup", "Sweet Deans.", "Go Human Beings!"].randomElement()
        case "ball":
            text.text = "Troy: Man, I do like sports. But right now I'd rather hang out with my friends."
            ball.run(.applyImpulse(CGVector(dx: 0, dy: 250), duration: 0.125))
        case "exit":
            text.text = "Thank you for playing.\nEnjoy WWDC20! :)"
        case "plant":
            text.text = "Britta: That's a nice plant."
        case "table":
            text.text = "Jeff: Again, the table helped us... studying."
        default: return
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        if event.keyCode == 0 {
            //move left
            moveCam = -2
        }else if event.keyCode == 2 {
            //move right
            moveCam = 2
        }
    }
    
    public override func keyUp(with event: NSEvent) {
        moveCam = nil
    }
    
    public override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    public override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // move camera if A / D is pressed
        guard let camera = camera, let moveCam = moveCam else { return }
        let newX = camera.position.x + moveCam
        guard newX > 0, newX < 660 else { return }

        self.camera!.position.x = newX
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(point.x - x), Float(point.y - y)))
    }
}
