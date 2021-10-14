using UnityEditor;
using UnityEngine;

namespace Gamekit3D
{
    [ExecuteInEditMode]
    public class GlobalShaderSettings : MonoBehaviour
    {

        [SerializeField]
        float TopScale = 1;
        [SerializeField]
        float NormalDetailScale = 1;
        [SerializeField]
        float NoiseAmount = 1;
        [SerializeField]
        float NoiseFalloff = 1;
        [SerializeField]
        float NoiseScale = 1;
        [SerializeField]
        float FresnelAmount = 0.5f;
        [SerializeField]
        float FresnelPower = 0.5f;

        private static readonly int Scale = Shader.PropertyToID("_TopScale");
        private static readonly int TopNormal2Scale = Shader.PropertyToID("_TopNormal2Scale");
        private static readonly int Amount = Shader.PropertyToID("_NoiseAmount");
        private static readonly int NoiseFallOff = Shader.PropertyToID("_NoiseFallOff");
        private static readonly int NoiseScaleProp = Shader.PropertyToID("_noiseScale");
        private static readonly int FresnelAmountProp = Shader.PropertyToID("_FresnelAmount");
        private static readonly int Power = Shader.PropertyToID("_FresnelPower");

        private void Update()
        {
            Shader.SetGlobalFloat(Scale, TopScale);
            Shader.SetGlobalFloat(TopNormal2Scale, NormalDetailScale);
            Shader.SetGlobalFloat(Amount, NoiseAmount);
            Shader.SetGlobalFloat(NoiseFallOff, NoiseFalloff);
            Shader.SetGlobalFloat(NoiseScaleProp, NoiseScale);
            Shader.SetGlobalFloat(FresnelAmountProp, FresnelAmount);
            Shader.SetGlobalFloat(Power, FresnelPower);
        }
    } 
}
