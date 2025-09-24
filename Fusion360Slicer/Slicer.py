#Author-
#Description-

from turtle import fd
import adsk.core, adsk.fusion, adsk.cam, traceback
import os, time

def run(context):
    ui = None
    try:
        app = adsk.core.Application.get()
        ui  = app.userInterface
        # ui.messageBox('Hello script')
        # app.documents.add(adsk.core.DocumentTypes.FusionDesignDocumentType)

        product = app.activeProduct
        design = adsk.fusion.Design.cast(product)

        # Get the output folder.
        fd = ui.createFolderDialog()
        fd.title = "Specify Output Folder"
        if fd.showDialog() != adsk.core.DialogResults.DialogOK:
            return

        resultFolder = fd.folder

        (sizeX, canceled) = ui.inputBox('Width')
        if canceled:
            return
        (sizeY, canceled) = ui.inputBox('Height')
        if canceled:
            return
        (layerCount, canceled) = ui.inputBox('Layers')
        if canceled:
            return

        # sizeX = "200"
        # sizeY = "200"
        # layerCount = "10"

        sizeX = int(sizeX)
        sizeY = int(sizeY)
        layerCount = int(layerCount)
      
        # setup scene settings used for rendering (not sure these are actually used)
        design.renderManager.sceneSettings.cameraType = adsk.core.CameraTypes.OrthographicCameraType
        design.renderManager.sceneSettings.aspectRatio = adsk.fusion.RenderAspectRatios.CustomRenderAspectRatio
        design.renderManager.sceneSettings.aspectRatioWidth = sizeX
        design.renderManager.sceneSettings.aspectRatioHeight = sizeY

        # setup scene rendering using the render manager 
        rendering = design.renderManager.rendering

        rendering.aspectRatio = adsk.fusion.RenderAspectRatios.CustomRenderAspectRatio
        rendering.isBackgroundTransparent = True
        rendering.resolutionWidth = sizeX
        rendering.resolutionHeight = sizeY

        # Reset our viewport to a consistent top down view
        viewport = app.activeViewport
        viewport.goHome(False)

        cam :adsk.core.Camera = viewport.camera

        cam.cameraType =  adsk.core.CameraTypes.OrthographicCameraType
        cam.viewOrientation = adsk.core.ViewOrientations.TopViewOrientation
        viewport.refresh()
        viewport.camera = cam
        viewport.fit()

        # Waiting for the viewport to settle
        time.sleep(3)
        
        def doRender(layer):
            design.renderManager.activateRenderWorkspace()
            
            # other render methods can be used
            # design.renderManager.inCanvasRendering.saveImage(resultFolder + '/layer_' + str(layer) + '.png')
            # app.activeViewport.saveAsImageFile(filename, 200, 200)
        
            renderFuture_var = rendering.startLocalRender(resultFolder + '/layer_' + str(layer) + '.png')
            renderState = renderFuture_var.renderState

            #ui.messageBox('Render State:\n{}'.format( renderState ))
            # wait until the render state is not 1
            while renderState == adsk.fusion.LocalRenderStates.QueuedLocalRenderState or renderState == adsk.fusion.LocalRenderStates.ProcessingLocalRenderState:
                time.sleep(.5)

                if renderFuture_var.isValid:
                    progress = renderFuture_var.progress

                print(progress)
                
                if renderFuture_var.isValid:
                    renderState = renderFuture_var.renderState
            
            # ui.messageBox('Render State:\n{}'.format( renderState ))

        rootComp = design.rootComponent

        createdPlanes = []

        minZ = rootComp.boundingBox.minPoint.z
        maxZ = rootComp.boundingBox.maxPoint.z

        nextBody = rootComp.bRepBodies[0]
        
        for layer in range(1, layerCount):
            nextBody.name = "obj_layer_" + str(layer)
            nextBody.isVisible = False

            plane = rootComp.constructionPlanes.createInput()
            plane.setByOffset(rootComp.xYConstructionPlane, adsk.core.ValueInput.createByReal((maxZ - minZ) * (layer / layerCount)))

            plane = rootComp.constructionPlanes.add(plane)
            plane.name = "plane_layer_" + str(layer)

            createdPlanes.append(plane)

            split: adsk.fusion.SplitBodyFeatureInput = rootComp.features.splitBodyFeatures.createInput(nextBody, plane, True)        
            feature = rootComp.features.splitBodyFeatures.add(split)
            nextBody = rootComp.bRepBodies[len(rootComp.bRepBodies) - 1]

            # the results of the split bodies can be accessed like this but then it affects the ordering and naming of the objects
            # feature.timelineObject.rollTo(True)
            # nextBody = feature.splitBodies[len(feature.splitBodies) - 1]
            # nextBody.name = "obj_layer_" + str(layer)

            # TODO: Use feature.bodies

        rootComp.bRepBodies[len(rootComp.bRepBodies) - 1].name = "obj_layer_" + str(layerCount)

        # Render each of our generated layers
        for layer in range(1, layerCount):
            obj = rootComp.bRepBodies.itemByName("obj_layer_" + str(layer))

            obj.isVisible = True

            doRender(layer)

            obj.isVisible = False

        # Make all objects visible at the end
        for layer in range(1, layerCount):
            obj = rootComp.bRepBodies.itemByName("obj_layer_" + str(layer))

            obj.isVisible = True

        design.workspaces[0].activate()

        ui.messageBox('Finished.')                

    except:
        if ui:
            ui.messageBox('Failed:\n{}'.format(traceback.format_exc()))
