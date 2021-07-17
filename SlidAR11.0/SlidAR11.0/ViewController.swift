//
//  ViewController.swift
//  SlidAR11.0
//
//  Created by 迟子皓 on 2020/11/10.
//

import UIKit
import SceneKit
import ARKit
import SwiftUI
import Accelerate
import simd
import UIKit.UIGestureRecognizerSubclass

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    @IBOutlet weak var PLUS: UIButton!
    @IBOutlet weak var MINUS: UIButton!
    @IBOutlet weak var Test: UIButton!
    
    @IBOutlet weak var Label: UILabel!
    
    
    let cone_height: Float = 0.03
    
    lazy var node: SCNNode = {

        let newNode = SCNNode(geometry: SCNSphere(radius: 0.0015))
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemRed

        return newNode
    }()

    lazy var newNode: SCNNode = {

        //let newNode = SCNNode(geometry: SCNTorus(ringRadius: 0.015, pipeRadius: 0.002))
        //let newNode = SCNNode(geometry: SCNPyramid(width: 0.05, height: 0.1, length: 0.05))
        let newNode  = SCNNode(geometry: SCNCone.init(topRadius: 0, bottomRadius: 0.01, height: CGFloat(cone_height)) )
        newNode.geometry?.firstMaterial?.diffuse.contents = UIColor.systemIndigo
        newNode.orientation = SCNVector4(0,0,1,0)
   
        print("hhhhh",newNode.position)
        configureLighting()
        return newNode
    
        
    }()

//     lazy var newNode: SCNNode = {
//
//        let scene = SCNScene(named: "ship.scn")!
//
//        var new = SCNNode()
//
//        new = scene.rootNode.childNodes.first!
//
//        //new.position = SCNVector3Zero
//
//        sceneView.scene = scene
//
//
//        print("Ori", new.position)
//        return new
//
//    }()
    
    var first_object_x:Float = 0.0
    var first_object_y:Float = 0.0
    var first_object_z:Float = 0.0
    
    var first_position_x: Float = 0.0
    var first_position_y: Float = 0.0
    var first_position_z: Float = 0.0
    
    var second_object_x: Float = 0.0
    var second_object_y: Float = 0.0
    var second_object_z: Float = 0.0
    
    typealias LAInt = __CLPK_integer

    var t:Float = 0.0
    
    var touched_number: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.session.delegate = self

        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "ship.scn")!

        //let node = scene.rootNode.childNode(withName: "ship", recursively: true)!

        // this puts the node in front & slightly below the camera
        let orientation = SCNVector3(x: 0, y: 0, z: -0.25)

        node.position = orientation

        let physicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(geometry: SCNSphere(radius: 0.1))
        )
        node.physicsBody = physicsBody

        sceneView.pointOfView?.addChildNode(node)
                
        print(node.position.x, node.position.y, node.position.z)
        
        // Set the scene to the view
        //sceneView.scene = scene
        
        Label.lineBreakMode = NSLineBreakMode.byWordWrapping
        Label.numberOfLines = 0
        
        Label.text = "Please move to any position and tap Confirm button.\nMaking the small red point intersects with the target object."
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    @discardableResult func updatecurrentcamerapose() ->(Float, Float, Float, Float, Float, Float){
        
//        guard let frame = sceneView.session.currentFrame else{return}
        let frame = sceneView.session.currentFrame
        
        let currentTransform = frame?.camera.transform
        let currentEulerAbgle = frame?.camera.eulerAngles
        let _ = frame?.camera.intrinsics
        
        let x = currentTransform!.columns.3.x
        let y = currentTransform!.columns.3.y
        let z = currentTransform!.columns.3.z
        
        let angleX = currentEulerAbgle!.x
        let angleY = currentEulerAbgle!.y
        let angleZ = currentEulerAbgle!.z
        
        return (x,y,z, angleX, angleY, angleZ)
    }
    
    var line1_a: Float = 0 {
        
        didSet{}
        
    }
    
    var line1_b: Float = 0 {
        
        didSet{}
        
    }
    
    var line1_c: Float = 0 {
        
        didSet{}
        
    }
    
    
    @IBAction func Confirm(_ sender: UIButton) {
        
        switch touched_number{
        case 0:
            first_position_x = updatecurrentcamerapose().0
            first_position_y = updatecurrentcamerapose().1
            first_position_z = updatecurrentcamerapose().2
            
            print(node.position.x, node.position.y, node.position.z)
            print(node.worldPosition.x, node.worldPosition.y, node.worldPosition.z)
            
            
            first_object_x = node.worldPosition.x
            first_object_y = node.worldPosition.y
            first_object_z = node.worldPosition.z
            
            newNode.position = SCNVector3(first_object_x, first_object_y + cone_height / 2, first_object_z)
            
            sceneView.scene.rootNode.addChildNode(newNode)
            
            line1_a = first_object_x - first_position_x
            line1_b = first_object_y - first_position_y
            line1_c = first_object_z - first_position_z
            
            //延长Epipolar line
            let t1: Float = -1000
            let t2: Float = 1000
            
            let line_start_x = first_position_x + line1_a * t1
            let line_start_y = first_position_y + line1_b * t1
            let line_start_z = first_position_z + line1_c * t1
            
            let line_end_x = first_position_x + line1_a * t2
            let line_end_y = first_position_y + line1_b * t2
            let line_end_z = first_position_z + line1_c * t2

            
            let line = SCNGeometry.line4(from: SCNVector3(line_start_x, line_start_y, line_start_z),to: SCNVector3(line_end_x, line_end_y, line_end_z), inScene: sceneView.scene)
            
            line.name = "line"
            
            //let lineNode = SCNNode(geometry: line)
            //line.position = SCNVector3Zero
            
            //lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
            
            sceneView.scene.rootNode.addChildNode(line)
            
            touched_number = touched_number + 1
            
            Label.text = "After tapping the Confirm button, please move to another place.\nMaking the small red point intersects with the target object and tap SlidAR button."
        default:
            return
        }
        
    }
    
    var second_position_x: Float = 0{
        
        didSet{}
        
    }
    
    //Get the second position y
    var second_position_y: Float = 0{
        
        didSet{}
        
    }
    
    //Get the second position z
    var second_position_z: Float = 0{
        
        didSet{}
        
    }
    
    @IBAction func SlidAR(_ sender: UIButton) {
        
        second_position_x = updatecurrentcamerapose().0
        second_position_y = updatecurrentcamerapose().1
        second_position_z = updatecurrentcamerapose().2
        
        second_object_x = node.worldPosition.x
        second_object_y = node.worldPosition.y
        second_object_z = node.worldPosition.z
        
        t = find_the_cloest_point().0
        
        newNode.position = SCNVector3(first_position_x + line1_a * t, (first_position_y + line1_b * t) + cone_height / 2, first_position_z + line1_c * t)
        print(newNode.position)
        
        Label.text = "Now you can tap PLUS or MINUS button to slightly move the purple cone.\nIf you don't satisfy your operation, please tap RESET button."
        
    }
    
    @discardableResult func find_the_cloest_point() ->(Float, Float) {

        let _: Float?
        let _: Float?
        ////Vector of line1
        let _:[Float] = [line1_a, line1_b, line1_c]

        
        let line2_a = second_object_x - second_position_x
        let line2_b = second_object_y - second_position_y
        let line2_c = second_object_z - second_position_z
        
        let _:[Float] = [line2_a, line2_b, line2_c]

        ///
        //let point_on_line1:[Float] = [updatecurrentcamerapose().0 + line1_a * line1_t!, updatecurrentcamerapose().1 + line1_b * line1_t!, updatecurrentcamerapose().2 + line1_c * line1_t!]
        //let point_on_line2:[Float] = [second_point_x + line2_a * line2_t!, second_point_y + line2_b * line2_t!, second_point_z + line2_c * line2_t!]

        //let vector_point1_point2:[Float] = [ point_on_line1[0] - point_on_line2[0], point_on_line1[1] - point_on_line2[1], point_on_line1[2] - point_on_line2[2] ]
        /// vector_point1_point2 * a = 0
        /// vector_point1_point2 * b = 0
        /// Equation 1:
        ///  line1_t * (line1_a * line1_a + line1_b * line1_b + line1_c * line1_c) + line2_t * (-line1_a * line2_a - line1_b * line2_b - line1_c * line2_c) = line1_a * (second_point_x - updatecurrentcamerapose().0) + line1_b * (second_point_y - updatecurrentcamerapose().1) + line1_c * (second_point_z - updatecurrentcamerapose().2)

        /// Equation 1:
        ///  line1_t * (line2_a * line1_a + line2_b * line1_b + line2_c * line1_c) + line2_t * (-line2_a * line2_a - line2_b * line2_b - line2_c * line2_c) = line2_a * (second_point_x - updatecurrentcamerapose().0) + line2_b * (second_point_y - updatecurrentcamerapose().1) + line2_c * (second_point_z - updatecurrentcamerapose().2)

        var A:[Float] = [
            line1_a * line1_a + line1_b * line1_b + line1_c * line1_c, line2_a * line1_a + line2_b * line1_b + line2_c * line1_c,
            -line1_a * line2_a - line1_b * line2_b - line1_c * line2_c, -line2_a * line2_a - line2_b * line2_b - line2_c * line2_c
        ]
        //var B:[Float] = [line1_a * (second_point_x - updatecurrentcamerapose().0) + line1_b * (second_point_y - updatecurrentcamerapose().1) + line1_c * (second_point_z - updatecurrentcamerapose().2), line2_a * (second_point_x - updatecurrentcamerapose().0) + line2_b * (second_point_y - updatecurrentcamerapose().1) + line2_c * (second_point_z - updatecurrentcamerapose().2) ]

        var B:[Float] = [line1_a * (second_position_x - first_position_x) + line1_b * (second_position_y - first_position_y) + line1_c * (second_position_z - first_position_z), line2_a * (second_position_x - first_position_x) + line2_b * (second_position_y - first_position_y) + line2_c * (second_position_z - first_position_z) ]
        
        let equations = 2

        var numberOfEquations:LAInt = 2
        var columnsIntA:LAInt = 2
        var elementsIntB:LAInt = 2

        var bSolutionCount:LAInt = 1

        var outputOk:LAInt = 0
        /// [0,0,0]
        var pivot = [LAInt](repeating: 0, count: equations)
        
        sgesv_(&numberOfEquations, &bSolutionCount, &A, &columnsIntA, &pivot, &B, &elementsIntB, &outputOk)

        print(outputOk)
        
        print("The Value of T1 is: ",B[0])
        print("The Value of T2 is: ",B[1])
        
        
        return (B[0], B[1])
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        
        if PLUS!.isHighlighted{
            t = t + 0.005
            print(t)
            newNode.position = SCNVector3(first_position_x + line1_a * t, (first_position_y + line1_b * t) + cone_height / 2, first_position_z + line1_c * t)
        }
        
        if MINUS!.isHighlighted{

            t = t - 0.005
            print(t)
            newNode.position =  SCNVector3(first_position_x + line1_a * t, (first_position_y + line1_b * t) + cone_height / 2, first_position_z + line1_c * t)
        }
        
        
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
        newNode.removeFromParentNode()
        for node in sceneView.scene.rootNode.childNodes {
            if node.name == "line" {
                node.removeFromParentNode()
            }
        }
        
        touched_number = 0
        
        Label.text = "Please move to any position and tap CONFIRM button.\nMaking the small red point intersects with the target object."

        
    }
    
    
}

extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3, color: UIColor)-> SCNNode {
        
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geo = SCNGeometry(sources: [source], elements: [element])
    
        geo.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        geo.firstMaterial?.diffuse.contents = color
        
        
        
        let final = SCNNode(geometry: geo)
        
        return final
    }
    class func line1(from: SCNVector3, to: SCNVector3, color : UIColor) -> SCNNode {
        let vertices: [SCNVector3] = [from, to]
        let data = NSData(bytes: vertices, length: MemoryLayout<SCNVector3>.size * vertices.count) as Data
        
        let vertexSource = SCNGeometrySource(data: data,
                                             semantic: .vertex,
                                             vectorCount: vertices.count,
                                             usesFloatComponents: true,
                                             componentsPerVector: 3,
                                             bytesPerComponent: MemoryLayout<Float>.size,
                                             dataOffset: 0,
                                             dataStride: MemoryLayout<SCNVector3>.stride)
        
        
        let indices: [Int32] = [ 0, 1]
        
        let indexData = NSData(bytes: indices, length: MemoryLayout<Int32>.size * indices.count) as Data
        
        let element = SCNGeometryElement(data: indexData,
                                         primitiveType: .line,
                                         primitiveCount: indices.count/2,
                                         bytesPerIndex: MemoryLayout<Int32>.size)
        
        let line = SCNGeometry(sources: [vertexSource], elements: [element])
        
        line.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant
        line.firstMaterial?.diffuse.contents = color
        
        let lineNode = SCNNode(geometry: line)
        return lineNode
    }
    class func line3(from : SCNVector3, to : SCNVector3, width : Int, color : UIColor) -> SCNNode {
        //let vector: [SCNVector3] = [to , from]
        let length = CGFloat(sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y) + (from.z - to.z) * (from.z - to.z)))
        
        let cylinder = SCNCylinder(radius: 0.005, height: CGFloat(length))
        cylinder.radialSegmentCount = width
        cylinder.firstMaterial?.diffuse.contents = color
        
        let node = SCNNode(geometry: cylinder)
        
        node.position = SCNVector3((to.x + from.x) / 2, (to.y + from.y) / 2, (to.z + from.z) / 2)
        node.eulerAngles = SCNVector3Make(Float(Double.pi/2), acos((to.z-from.z)/Float(length)), atan2((to.y-from.y), (to.x-from.x) ))
        
        return node
    }
    class func line4(from: SCNVector3, to: SCNVector3, inScene: SCNScene) -> SCNNode {
        let vector = SCNVector3(from.x - to.x, from.y - to.y, from.z - to.z)
        let distance = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        let midPosition = SCNVector3 (x:(from.x + to.x) / 2, y:(from.y + to.y) / 2, z:(from.z + to.z) / 2)

        let lineGeometry = SCNCylinder()
        lineGeometry.radius = 0.0004
        lineGeometry.height = CGFloat(distance)
        lineGeometry.radialSegmentCount = 5
        lineGeometry.firstMaterial!.diffuse.contents = UIColor.green

        let lineNode = SCNNode(geometry: lineGeometry)
        lineNode.position = midPosition
        lineNode.look (at: to, up: inScene.rootNode.worldUp, localFront: lineNode.worldUp)
        return lineNode
    }
    

}

