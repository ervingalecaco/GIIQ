using System.Data;
using Dapper;

namespace LabQuim.Api.Data;

/// <summary>
/// MySqlConnector devuelve las columnas DATE como DateTime; este handler permite
/// mapearlas a DateOnly (lectura) y enviar DateOnly como parámetro (escritura).
/// </summary>
public sealed class DateOnlyTypeHandler : SqlMapper.TypeHandler<DateOnly>
{
    public override DateOnly Parse(object value) => value switch
    {
        DateOnly d => d,
        DateTime dt => DateOnly.FromDateTime(dt),
        string s => DateOnly.Parse(s),
        _ => throw new DataException($"No se puede convertir {value?.GetType()} a DateOnly.")
    };

    public override void SetValue(IDbDataParameter parameter, DateOnly value)
    {
        parameter.DbType = DbType.Date;
        parameter.Value = value.ToDateTime(TimeOnly.MinValue);
    }
}
