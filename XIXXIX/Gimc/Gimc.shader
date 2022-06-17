Shader "XIXXIX/Gimc"
{
	Properties
	{
		[Header(Main)]
		_MainColor("Main Color", Color) = (0.5,0.5,0.5,0)
		_MainTex("Main Tex", 2D) = "white" {}
		[Header(Emission)]
		_LerpEmission("Lerp Emission", Range( 0 , 1)) = 0
		_EmissionColor("Emission Color", Color) = (0.5,0.5,0.5,0)
		_EmissionTex("Emission Tex", 2D) = "white" {}
		[Header(Custom Lighting)]
		_LightStrength("Light Strength", Float) = 1
		_LightOffset("Light Offset", Float) = 1
		[Header(RimLight)]
		_LerpRimLight("Lerp RimLight", Range( 0 , 1)) = 0
		_RimLightColor("RimLight Color", Color) = (1,1,1,0)
		_RimLightStrength("RimLight Strength", Float) = 1
		_RimLightOffset("RimLight Offset", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float3 viewDir;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _EmissionTex;
		uniform float4 _EmissionTex_ST;
		uniform float4 _EmissionColor;
		uniform float _LerpEmission;
		uniform float4 _RimLightColor;
		uniform float _RimLightStrength;
		uniform float _RimLightOffset;
		uniform float _LerpRimLight;
		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _MainColor;
		uniform float _LightStrength;
		uniform float _LightOffset;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 Main216 = ( tex2D( _MainTex, uv_MainTex ) * _MainColor );
			float4 color185 = IsGammaSpace() ? float4(0.2,0.2,0.2,0) : float4(0.03310476,0.03310476,0.03310476,0);
			float4 color186 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float3 ase_worldNormal = i.worldNormal;
			float dotResult162 = dot( _WorldSpaceLightPos0.xyz , ase_worldNormal );
			float LightDir176 = dotResult162;
			float4 lerpResult187 = lerp( color185 , color186 , ( saturate( ( LightDir176 * _LightStrength ) ) + ( _LightStrength * _LightOffset ) ));
			float4 CustomLighting190 = lerpResult187;
			float4 CLZSM192 = ( Main216 * CustomLighting190 );
			c.rgb = CLZSM192.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			float4 temp_cast_0 = (0.0).xxxx;
			float2 uv_EmissionTex = i.uv_texcoord * _EmissionTex_ST.xy + _EmissionTex_ST.zw;
			float4 lerpResult246 = lerp( temp_cast_0 , ( tex2D( _EmissionTex, uv_EmissionTex ) * _EmissionColor ) , _LerpEmission);
			float4 EmissionTex242 = lerpResult246;
			float4 temp_cast_1 = (0.0).xxxx;
			float4 color203 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float3 ase_worldNormal = i.worldNormal;
			float dotResult196 = dot( ase_worldNormal , i.viewDir );
			float4 lerpResult201 = lerp( _RimLightColor , color203 , saturate( ( ( dotResult196 * _RimLightStrength ) + ( 1.0 - _RimLightOffset ) ) ));
			float4 lerpResult253 = lerp( temp_cast_1 , lerpResult201 , _LerpRimLight);
			float4 RimLight208 = lerpResult253;
			float4 Emissionzsm209 = ( EmissionTex242 + RimLight208 );
			o.Emission = Emissionzsm209.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldNormal = IN.worldNormal;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}