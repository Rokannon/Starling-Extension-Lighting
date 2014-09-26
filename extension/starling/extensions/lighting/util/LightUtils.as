package starling.extensions.lighting.util
{
    import flash.geom.Vector3D;

    import starling.utils.deg2rad;

    /**
     * @author Szenia Zadvornykh
     */
    public class LightUtils
    {
        public static function vectorFromDegrees(deg:int, targetVector:Vector3D = null):Vector3D
        {
            return vectorFromRadians(deg2rad(deg), targetVector);
        }

        public static function vectorFromRadians(rad:Number, targetVector:Vector3D = null):Vector3D
        {
            var v:Vector3D = targetVector ? targetVector : new Vector3D();

            v.setTo(Math.cos(rad), Math.sin(rad), v.z);

            return v;
        }
    }
}
